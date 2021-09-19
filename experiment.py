import pandas as pd
import re
import os
import sys
import multiprocessing as mp
import time

print(os.environ['REPOPATH'])
print(os.environ['PYTHONPATH'])

import releasy
from releasy.miner_git import GitVcs
from releasy.miner import TagReleaseMiner, TimeVersionReleaseSorter, PathCommitMiner, RangeCommitMiner, TimeCommitMiner, TimeNaiveCommitMiner, VersionReleaseMatcher, VersionReleaseSorter, TimeReleaseSorter, VersionWoPreReleaseMatcher

threads = 10
#threads = 4

def analyze_project(name, lang, suffix_exception_catalog, release_exception_catalog):
    try:
        start = time.time()
        path = os.path.abspath(os.path.join(os.environ['REPOPATH'],name))
        if name in suffix_exception_catalog:
            suffix_exception = suffix_exception_catalog[name]
        else:
            suffix_exception = None
        if name in release_exception_catalog:
            release_exceptions = release_exception_catalog[name]
        else:
            release_exceptions = None
        
        vcs = GitVcs(path)
        release_matcher = VersionWoPreReleaseMatcher(suffix_exception=suffix_exception, 
                                                     release_exceptions=release_exceptions)
        release_miner = TagReleaseMiner(vcs, release_matcher)
        releases = release_miner.mine_releases()

        version_sorter = TimeVersionReleaseSorter()
        releases_wbase = version_sorter.sort(releases)

        path_miner = PathCommitMiner(vcs, releases)
        range_miner = RangeCommitMiner(vcs, releases_wbase)
        time_miner = TimeCommitMiner(vcs, releases_wbase)
        time_naive_miner = TimeNaiveCommitMiner(vcs, releases_wbase)
    
        path_release_set = path_miner.mine_commits()
        range_release_set = range_miner.mine_commits()
        time_release_set = time_miner.mine_commits()
        time_naive_release_set = time_naive_miner.mine_commits()
        
        stats = []
        for release in releases:
            if f"{name}@{release.name}" not in release_exception_catalog:
                path_commits = set(path_release_set[release.name].commits)
                range_commits = set(range_release_set[release.name].commits)
                time_commits = set(time_release_set[release.name].commits)
                time_naive_commits = set(time_naive_release_set[release.name].commits)
            
                path_base_releases = [release.name.value for release in (path_release_set[release.name].base_releases or [])]
                range_base_releases = [release.name.value for release in (range_release_set[release.name].base_releases or [])]
                time_base_releases = [release.name.value for release in (time_release_set[release.name].base_releases or [])]
                time_naive_base_releases = [release.name.value for release in (time_naive_release_set[release.name].base_releases or [])]

                stats.append({
                    "project": name,
                    "name": release.name.value,
                    "version": release.name.version,
                    "semantic_version": release.name.semantic_version,
                    "prefix": release.name.prefix,
                    "suffix": release.name.suffix,
                    "lang": lang,
                    "head": str(release.head.id),
                    "time": release.time,
                    "committers": len(path_release_set[release.name].committers),
                    "commits": len(path_commits),
                    "merges": len(path_release_set[release.name].merges),
                    "base_releases": path_base_releases,
                    "base_releases_qnt": len(path_base_releases),
                    "range_commits": len(range_commits),
                    "range_base_releases": range_base_releases,
                    "range_tpos": len(path_commits & range_commits),
                    "range_fpos": len(range_commits - path_commits),
                    "range_fneg": len(path_commits - range_commits),
                    "time_commits": len(time_commits),
                    "time_base_releases": time_base_releases,
                    "time_tpos": len(path_commits & time_commits),
                    "time_fpos": len(time_commits - path_commits),
                    "time_fneg": len(path_commits - time_commits),
                    "time_naive_commits": len(time_naive_commits),
                    "time_naive_base_releases": time_naive_base_releases,
                    "time_naive_tpos": len(path_commits & time_naive_commits),
                    "time_naive_fpos": len(time_naive_commits - path_commits),
                    "time_naive_fneg": len(path_commits - time_naive_commits)
                })
        releases = pd.DataFrame(stats)
        print(f"{time.time() - start:10} - {name}") 
        return releases
    except Exception as e:
        print(f" {name} - error: {e}")

if __name__ ==  '__main__':
    from projects import projects
    from exceptions import release_exception_catalog, suffix_exception_catalog

    releases = pd.DataFrame()
        
    # pool = mp.Pool(processes=10, maxtasksperchild=10)
    pool = mp.Pool(processes=threads, maxtasksperchild=threads)
    results = [pool.apply_async(analyze_project, args=(name, metadata["lang"], suffix_exception_catalog, release_exception_catalog)) for name, metadata in projects.items()]
    data = [p.get() for p in results]
    releases = pd.concat(data)

    releases.commits = pd.to_numeric(releases.commits)
    releases.time = pd.to_datetime(releases.time, utc=True)
    releases.range_commits = pd.to_numeric(releases.range_commits)
    releases.range_tpos = pd.to_numeric(releases.range_tpos)
    releases.range_fpos = pd.to_numeric(releases.range_fpos)
    releases.range_fneg = pd.to_numeric(releases.range_fneg)
    releases.time_commits = pd.to_numeric(releases.time_commits)
    releases.time_tpos = pd.to_numeric(releases.time_tpos)
    releases.time_fpos = pd.to_numeric(releases.time_fpos)
    releases.time_fneg = pd.to_numeric(releases.time_fneg)
    releases = releases.set_index(['project', 'name'])

    releases.to_pickle("raw_releases.zip")
    releases.to_csv("raw_releases.csv")

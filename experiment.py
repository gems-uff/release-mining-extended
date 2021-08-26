import re
import os
import sys
import time

import pandas as pd

print(os.environ['REPOPATH'])
print(os.environ['PYTHONPATH'])

import releasy
from releasy.miner_git import GitVcs
from releasy.miner import TagReleaseMiner, TimeVersionReleaseSorter, PathCommitMiner, RangeCommitMiner, TimeCommitMiner, TimeNaiveCommitMiner, VersionReleaseMatcher, VersionReleaseSorter, TimeReleaseSorter, VersionWoPreReleaseMatcher
from releasy.developer import DeveloperTracker

threads = 1

def analyze_project(name, lang, suffix_exception_catalog, release_exception_catalog):
    try:
        start_time = time.time()
        path = os.path.abspath(os.path.join(os.environ['REPOPATH'], name))
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

        path_miner = PathCommitMiner(vcs, releases)
        path_release_set = path_miner.mine_commits()
        
        project_size = os.path.getsize(path)
        developers = set()
        stats = []
        n_commits = 0
        n_merges = 0
        n_releases = 0 

        for release in path_release_set:
            if f"{name}@{release.name}" not in release_exception_catalog:
                path_commits = set(path_release_set[release.name].commits)
                path_base_releases = [release.name.value for release in (path_release_set[release.name].base_releases or [])]
                n_commits += len(path_commits)
                n_merges += len(path_release_set[release.name].merges)
                n_releases += 1
                for developer in release.committers:
                    developers.add(developer)

        elapsed_time = time.time() - start_time
        stats = {
            "project": name,
            "releases": n_releases,
            "commits": n_commits,
            "merges": n_merges,
            "developers": len(developers),
            "size": project_size,
            "elapsed_time": elapsed_time
        }
        project = pd.DataFrame.from_records([stats])
        print(f"{elapsed_time:10} - {name}") 
        return project
    except Exception as e:
        print(f" {name} - error: {e}")

if __name__ == "__main__":
    projects = pd.DataFrame()
    for round in range(10):
        project = analyze_project("d3/d3", "None", {}, {})
        project["round"] = round
        projects = projects.append(project)
    print(projects)
    

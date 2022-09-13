import re
import os
import sys
import time

print(os.environ['REPOPATH'])
print(os.environ['PYTHONPATH'])

import releasy
from releasy.miner_git import GitVcs
from releasy.miner import TagReleaseMiner, TimeVersionReleaseSorter, PathCommitMiner, RangeCommitMiner, TimeCommitMiner, TimeNaiveCommitMiner, VersionReleaseMatcher, VersionReleaseSorter, TimeReleaseSorter, VersionWoPreReleaseMatcher
from releasy.developer import DeveloperTracker

threads = 1

def analyze_project(name, lang, suffix_exception_catalog, release_exception_catalog):
    try:
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

        return path_release_set
    except Exception as e:
        print(f" {name} - error: {e}")

baseline_tests = {
    'tmux/tmux': [
        '2.4', '2.6', '1.2', '1.0', '1.5', '0.8', '2.3', '1.1', '3.0', '1.3'
    ], 
    'MaterialDesignInXAML/MaterialDesignInXamlToolkit': [
        'v2.3.0', 'v3.2.0', 'v3.0.0', 'v2.1.0', 'v2.2.0', '2.6.0', '3.1.1', 'v1.5.0', 'v3.1.3', 'v2.0.0'
    ],
    'electron/electron': [
        'v0.10.4', 'v6.0.0', 'v4.0.5', 'v4.2.0', 'v0.15.5', 'v8.0.3', 'v1.6.2', 'v0.32.0', 'v0.11.7', 'v0.20.2'
    ],
    'v2ray/v2ray-core': [
        'v0.14.1', 'v2.19', 'v4.20.0', 'v0.13', 'v1.14', 'v4.16.1', 'v3.30', 'v2.20', 'v0.6.1', 'v2.16.4'
    ],
    'elastic/elasticsearch': [ 
        'v0.90.9', 'v0.90.6', 'v5.4.2', 'v1.4.4', 'v5.4.0', 'v1.4.5', 'v7.6.2', 'v0.90.3', 'v7.9.1', 'v5.4.1'
    ],
    'vercel/next.js': [ 
        '3.0.2', '3.2.3', 'v8.0.4', '2.4.4', 'v9.3.0', '1.1.1', '2.2.0', '1.1.2', '2.1.1', '4.1.2'
    ],
    'laravel/laravel': [
        'v5.6.21', 'v5.4.23', 'v3.2.5', 'v4.0.5', 'v6.2.0', 'v3.0.4', 'v5.1.1', 'v5.4.3', 'v5.2.27', 'v5.3.0'
    ],
    'XX-net/XX-Net': [
        '3.6.3', '1.3.6', '3.11.9', '3.8.2', '3.10.8', '3.8.0', '1.13.6', '4.3.0', '3.6.9', '3.14.2'
    ],
    'CocoaPods/CocoaPods': [
        '0.22.3', '1.7.5', '0.3.0', '0.3.1', '0.0.7', '1.7.1', '0.38.2', '0.5.0', '0.16.0', '0.35.0'
    ],
    'microsoft/TypeScript': [ 
        'v2.6.0', 'v2.1.4', 'v2.4.1', 'v2.1.5', 'v2.5.3', 'v3.7.4', 'v2.7.2', 'v2.7.1', 'v1.8.7', 'v3.2.1'
    ]
}

if __name__ == "__main__":
    from exceptions import release_exception_catalog, suffix_exception_catalog

    for project_path, release_names in baseline_tests.items():
        releases = analyze_project(project_path, "None", suffix_exception_catalog, release_exception_catalog)
        for name in release_names:
            commits = set(releases[name].commits)
            output_file = f"./data/rsamples/{project_path.replace('/', '-')}-{name}.releasy"
            print(project_path, output_file, name, len(commits))
            with open(output_file, 'w') as output:
                for commit in sorted(commits, key=lambda commit: commit.hashcode):
                    output.write(f"{commit.hashcode}\n")
            

    

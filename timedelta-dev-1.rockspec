local package_name = "timedelta"
local package_version = "dev"
local rockspec_revision = "1"
local github_account_name = "nathanrpage97"
local github_repo_name = package_name
local git_checkout = package_version == "dev" and "master" or package_version

package = package_name
version = package_version .. "-" .. rockspec_revision

rockspec_format = "3.0"
source = {
    url = "git://github.com/" .. github_account_name .. "/" .. package_name,
    tag = git_checkout
}

description = {
    summary = "A lua implemnetation of the python datetime.timedelta object",
    detailed = [[
        A lua implemnetation of the python datetime.timedelta object
    ]],
    homepage = "https://" .. github_account_name .. ".github.io/" ..
        github_repo_name,
    license = "MIT"
}

dependencies = {"lua >= 5.1"}

build = {type = "builtin", modules = {timedelta = "timedelta.lua"}}

test_dependencies = {"busted"}

test = {type = "busted"}


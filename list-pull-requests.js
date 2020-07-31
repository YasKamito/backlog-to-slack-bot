import rp from "request-promise"
import moment from "moment"

const main = (token, owner, repos, since, until) => {
  const sinceTime = Date.parse(since)
  const untilTime = (until) ? Date.parse(until) : Date.now()
  repos.forEach(repo => {
    for (var page = 1; page <= 10; page++) {
        listPullRequests(token, owner, repo, sinceTime, untilTime, page)
    }
  })
}

const listPullRequests = (token, owner, repo, sinceTime, untilTime, page) => {
  const url = `https://api.github.com/repos/${owner}/${repo}/pulls?per_page=100&page=${page}&state=closed`
  rp(url, fetchOptions(token))
    .then((response) => {
      return JSON.parse(response)
    })
    .then((prs) => {
      console.log(" # " + repo)
      prs.forEach((pr) => {
        if (pr.merged_at) {
          const mergedTime = Date.parse(pr.merged_at)
          if (sinceTime <= mergedTime && mergedTime < untilTime) {
            console.log("   - " + pr.title + " (close:" + moment(new Date(pr.closed_at)).format("YYYY/MM/DD hh:mm)"))
            console.log("     - " + pr.html_url)
          }
        }
      })
      console.log("")
    })
    .catch((error) => {
      console.log(error)
    })
}

const fetchOptions = (token) => {
  return {
    method: "GET",
    headers: {
      "User-Agent": "request",
      Authorization: `token ${token}`
    },
    isJson: true,
  }
}

const usage = () => {
  console.log("List up the PRs which are merged in the specified period.")
  console.log("Usage: npm start <api_access_token> <owner> <repositories> <since> <until>")
  console.log("  <access_token>")
  console.log("    Access token for github api, [repo] must be checked.")
  console.log("    To generate token, access to 'https://github.com/settings/tokens' and click [generate new token]")
  console.log("  <owner>")
  console.log("    Specify the owner of github repositories.")
  console.log("  <repositories>")
  console.log("    Specify the github repositories separated by comma. ex) aaa,bbb")
  console.log("  <since>")
  console.log("    Specify the 'since' time, don't forget to add timezone.")
  console.log("    The PRs merged at 'since' time contain the result.")
  console.log("    ex) \"2019-01-01 00:00:00 +9:00\" (JST case)")
  console.log("  <until>")
  console.log("    An optional parameter.")
  console.log("    If omitted, the PPs merged after 'since' time (no until condition) will be listed-up.")
  console.log("    Specify the 'until' time, don't forget to add timezone.")
  console.log("    The PRs merged at 'until' time *DO NOT* contain the result.")
  console.log("    ex) \"2019-01-31 00:00:00 +9:00\" (JST case)")
}

const parseArgs = (argv) => {
  if(argv.length < 8) return undefined
  if(isNaN(Date.parse(argv[7]))) {
    console.error(`<since> time "${argv[7]}" is not date format. Specify correct format. Ex) "2019-01-01 00:00:00 +9:00"`)
    return undefined
  }
  if(argv[8] && isNaN(Date.parse(argv[8]))) {
    console.error(`<until> time "${argv[8]}" is not date format. Specify correct format. Ex) "2019-01-02 00:00:00 +9:00"`)
    return undefined
  }
  return {
    token : argv[4],
    owner: argv[5],
    repos: argv[6].split(","),
    since: argv[7],
    until: argv[8],
  }
}

const config = parseArgs(process.argv)
if (config) {
  main(config.token, config.owner, config.repos, config.since, config.until)
} else {
  usage()
}

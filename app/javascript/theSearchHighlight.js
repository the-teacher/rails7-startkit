// Simple implementation of search results highlighting on FE side
const TheSearchHighlight = (() => {
  const SEARCH_WORDS_NAME = 'searchWords'

  const TMP_START_TAG = '!_A_!'
  const TMP_END_TAG = '!_Z_!'

  const START_TAG = '<em class="tsh">'
  const END_TAG = '</em>'

  let wordsToHighlight = []

  const prepareSearchKeyword = (searchKeyword) => {
    return searchKeyword.trim().replace(/\s\s+/g, ' ')
  }

  const getFragmentsToHighlight = (highlightSelector) =>
    document.querySelectorAll(highlightSelector)

  const getWordsToSearch = (fragment) => {
    const searchKeywords = JSON.parse(fragment.dataset[SEARCH_WORDS_NAME])
    return searchKeywords.map((searchKeyword) => {
      return prepareSearchKeyword(searchKeyword).split(' ')
    }).flat()
  }

  const highlighterBuilder = (wordsToSearch) => {
    return (str) => {
      wordsToSearch.forEach(wordToSearch => {
        const regExp = new RegExp(wordToSearch, 'gi')
        const matches = [...str.matchAll(regExp)]
        const uniqMatchedWords = matches.map((aryItem) => aryItem[0])
        const matchedWords = [...new Set(uniqMatchedWords)]

        if (matchedWords.length) {
          matchedWords.forEach((foundWord) => {
            const _regExp = new RegExp(foundWord, 'g')
            str = str.replaceAll(_regExp, `${TMP_START_TAG}${foundWord}${TMP_END_TAG}`)
          })
        }
      })
      return str
    }
  }

  const recursiveChildrenRunner = (element, highlighter) => {
    for (const child of element.children) {
      recursiveChildrenRunner(child, highlighter)

      for (var element of child.childNodes) {
        if (element.nodeType === Node.TEXT_NODE) {
          const oldText = element.nodeValue
          const newText = highlighter(element.nodeValue)
          if (oldText !== newText) {
            element.nodeValue = newText
          }
        }
      }
    }
  }

  const highlightFragment = (fragment) => {
    const wordsToSearch = getWordsToSearch(fragment)
    if (!wordsToSearch.length) { return }
    const highlighter = highlighterBuilder(wordsToSearch)
    recursiveChildrenRunner(fragment, highlighter)
  }

  return {
    init: (highlightSelector) => {
      const fragments = getFragmentsToHighlight(highlightSelector)
      fragments.forEach((fragment) => {
        highlightFragment(fragment)
        fragment.innerHTML = fragment.innerHTML
          .replaceAll(TMP_START_TAG, START_TAG)
          .replaceAll(TMP_END_TAG, END_TAG);
      })
    }
  }
})()

export default TheSearchHighlight

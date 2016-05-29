# encoding: utf-8

import json
import sys
import time
import urllib
import codecs

from urllib.parse import urlencode
from urllib.request import build_opener, Request, ProxyHandler

DBPediaEndpoint = "http://dbpedia.org/sparql"
# DBPediaEndpoint = "http://nlctranslator59:8890/sparql"

# интервал (в секундах) между запросами
SleepPeriod = 0
# интервал перед следующим запросом после ошибки
ErrorSleepPeriod = 3

personsTemplate = \
"""SELECT distinct ?uri, ?wikiLink WHERE {
	?uri rdf:type dbo:Person .
	{ ?uri foaf:givenName ?name } union { ?uri foaf:surname ?name } .
	?uri foaf:isPrimaryTopicOf ?wikiLink .
}
"""

# Отправить get-запрос, вернуть результат
def sendGetRequest(requestText, baseUrl):
	params = urlencode({'query': requestText, 'timeout': 3000000})
	proxy = ProxyHandler({})
	opener = build_opener(proxy)
	request = Request(baseUrl + '?' + params)
	request.add_header('Accept', 'application/json')
	request.get_method = lambda: 'GET'
	url = opener.open(request)
	return url.read()

# разбирает json-ответ, возвращает список строк (в виде списков) и названия столбцов
def parseResult(jsonResponse):
	data = json.loads(jsonResponse)
	columns = data['head']['vars']
	values = []
	for entrySrc in data['results']['bindings']:
		entry = [entrySrc[cname]['value'] for cname in columns]
		values.append(entry)
	return values, columns

def iterativeRequest(requestText, outputFileName):
	limit = 10000
	offset = 0
	resultSize = limit
	totalValues = 0
	while resultSize == limit:
		# обернем запрос как вложенный, зададим ограничения и текущий offset
		# (http://virtuoso.openlinksw.com/dataspace/doc/dav/wiki/Main/VirtTipsAndTricksHowToHandleBandwidthLimitExceed)
		request = 'select * where { ' + requestText + 'order by ?label }\noffset %d\nlimit %d' % (offset, limit)
		# print(request)
		done = False
		while not done:
			try:
				result = sendGetRequest(request, DBPediaEndpoint)
				done = True
			except Exception as err:
				print('Error while processing request: %s' % err)
				time.sleep(ErrorSleepPeriod)

		values, columns = parseResult(result.decode('utf-8'))

		with codecs.open(outputFileName, 'a', encoding='utf-8') as fout:
			fout.write('\n'.join(['\t'.join(entry) for entry in values]) + '\n')

		resultSize = len(values)
		totalValues += len(values)
		print('total values: %d' % totalValues)
		offset += limit
		time.sleep(SleepPeriod)

def main(requestText, outputFileName):
	try:
		iterativeRequest(requestText, outputFileName)
	except Exception as err:
		print('Error in iterativeRequest: %s' % err)
		return 2

if __name__ == '__main__':
	outputFileName = sys.argv[-1]
	try:
		open(outputFileName, 'w').close()
		exit(main(personsTemplate, outputFileName))
	except Exception as err:
		print(err)
		exit(1)

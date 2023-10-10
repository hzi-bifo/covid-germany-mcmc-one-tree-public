import sys
from datetime import datetime as dt
import time
import csv

def toYearFraction(date):
    def sinceEpoch(date): # returns seconds since epoch
        return time.mktime(date.timetuple())
    date = dt.strptime(date, '%Y-%m-%d')
    s = sinceEpoch

    year = date.year
    startOfThisYear = dt(year=year, month=1, day=1)
    startOfNextYear = dt(year=year+1, month=1, day=1)

    yearElapsed = s(date) - s(startOfThisYear)
    yearDuration = s(startOfNextYear) - s(startOfThisYear)
    fraction = yearElapsed/yearDuration

    return date.year + fraction


dates = []
with open(sys.argv[1], mode='r') as infile:
    reader = csv.reader(infile, delimiter='\t')
    id_index = date_index = None
    for row in reader:
        if id_index is None:
            date_index = row.index('Collection date')
            id_index = row.index('Accession ID')
        else:
            try:
                dates.append((row[id_index], toYearFraction(row[date_index])))
            except ValueError:
                pass

print('{}'.format(len(dates)))
for r in dates:
    print(' '.join([str(x) for x in r]))


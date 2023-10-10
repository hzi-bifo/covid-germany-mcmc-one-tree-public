import sys
import csv

metadata_ids = []
with open(sys.argv[2]) as f:
	reader = csv.DictReader(f, delimiter='\t', quotechar='|')
	for row in reader:
		metadata_ids.append(row['Accession ID'])

def wrap(s, l):
	r = ''
	st = 0
	while len(s) > st:
		if st > 0: r += '\n'
		r += s[st:st+l]
		st += l
	return r

metadata_ids = set(metadata_ids)
with open(sys.argv[1]) as f:
	for head in f:
		seq = next(f)
		head_split = head[1:].split('|')
		if head_split[1] in metadata_ids:
			print('>{}'.format(head_split[1]))
			print(wrap(seq.strip(), 60))
	

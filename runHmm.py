#!/usr/bin/python
import os
import glob
import ntpath
import sys
import argparse
import subprocess
from Bio import SearchIO
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn import preprocessing

def loopfiles(args, list_path):
	# create output dir
	if not os.path.exists(str(args.out)):
		os.makedirs(args.out)
	# open output file
	f = open(list_path,'w')
	# check if files are provided
	fastalist = filter(os.path.isfile, glob.glob(str(args.fasta) +'/*.fasta'))
	if not fastalist:
		sys.stderr.write("No fasta files found.\n")
		# walk through subdirs
		path, subdirs, files = os.walk(str(args.fasta))
		if not files:
			sys.stderr.write("No files in subdirectory found.\n")
			exit(1)
		else:
			print("Subdirectories found.")
			# subdirs are present, list the fasta files found in subdirs
			for path, subdirs, files in os.walk(str(args.fasta)):
				for filename in files:
					fasta_file = os.path.join(path, filename)
					#print fasta_file
					runHmmer(args, list_path, fasta_file, f)
			f.close()
		#exit(1)
	else:
		# we have fasta files without subfolders
		for filename in fastalist:
			runHmmer(args, list_path, filename, f)
		f.close()

def runHmmer(args, list_path, file_path, f):
	# get the sample group
	head, group = os.path.split(os.path.split(file_path)[0])
	basename = os.path.splitext(str(ntpath.basename(str(file_path))))[0]
	exportpath = str(args.out) + ntpath.basename(str(file_path))
	hmmpath = str(args.out) + ntpath.basename(str(file_path)) + '.out'
	print('Processing %s of group %s' % (basename, group))
	s = " "
	cmd = ("prodigal -p meta -i",  str(file_path), "-a", exportpath, '-d /dev/null > /dev/null 2> /dev/null')
	os.system(s.join( cmd ))
	# run hmmsearch on faa ORF files
	s = " "
	cmd = ("hmmsearch -E 0.001 --domtblout", hmmpath, args.hmm, exportpath, '> /dev/null 2> /dev/null')
	os.system(s.join( cmd ))
	#print(s.join( cmd ))
	# parse domtblout and save it as csv
	with open(hmmpath, 'rU') as input:
		try:
			for qresult in SearchIO.parse(input, 'hmmscan3-domtab'):
				query_id = qresult.id
				hits = qresult.hits
				num_hits = len(hits)
				acc = qresult.accession
				if args.query:
					f.write(''.join((basename, '\t', str(query_id),'\t', str(num_hits),'\t', str(group), '\n')))
				else:
					f.write(''.join((basename, '\t', str(acc),'\t', str(num_hits), '\t', str(group),'\n')))
		except ValueError:
			print('parsing error on %s' % basename)

def drawCluster(filename, args):
	df = pd.read_table(filename, header=None)
	df.columns = ['file', 'name','num','group']

	if pd.unique(df['group']).size >= 2:

if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument('--hmm', action='store', dest='hmm',
						help='path to hmm file', default='example/example.hmm')
	parser.add_argument('--fasta_dir', action='store', dest='fasta',
						help='path to folder where .fasta files are located (fasta files can be grouped within subfolder)', default='example/faa')
	parser.add_argument('--output_dir', action='store', dest='out',
						help='path to output folder', default='output/')
	parser.add_argument('--use_query', action='store_true', dest='query',
						help='use query id insead of accession')
	parser.add_argument('--colorful', action='store_true', dest='colorful',
						help='use colors for heatmap')
	parser.add_argument('--normalize', action='store_true', dest='normalize',
						help='normalize cluster map')
	parser.add_argument('--keep_order', action='store_true', dest='keeporder',
						help='do not cluster rows if groups are present')

	parser.add_argument('--version', action='version', version='%(prog)s 0.1')
	args = parser.parse_args()

	# start looping thorugh the files and run prodigal and hmmer to create the csv file
	loopfiles(args, args.out + str('hits_list.csv'))

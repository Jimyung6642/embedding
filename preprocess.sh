#!/usr/bin/env bash

COMMAND=$1

case $COMMAND in
    data_dump)
        echo "download naver movie corpus..."
        wget https://github.com/e9t/nsmc/raw/master/ratings.txt
        wget https://github.com/e9t/nsmc/raw/master/ratings_train.txt
        wget https://github.com/e9t/nsmc/raw/master/ratings_test.txt
        mv *.txt ../data
        echo "download ko-wikipedia..."
        wget https://dumps.wikimedia.org/kowiki/latest/kowiki-latest-pages-articles.xml.bz2 data/kowiki-latest-pages-articles.xml.bz2
        mv kowiki-latest-pages-articles.xml.bz2 data
        echo "processing ko-wikipedia..."
        python preprocess/wikidump.py data/kowiki-latest-pages-articles.xml.bz2 data/wiki_ko_raw.txt
        ;;
    space_correct)
        echo "processing naver movie corpus..."
        python preprocess/unsupervised_nlputils.py process_nvc data/ratings.txt data/processed_ratings.txt
        echo "apply space correct..."
        python preprocess/unsupervised_nlputils.py train_space data/processed_ratings.txt data/space.model
        python preprocess/unsupervised_nlputils.py apply_space_correct data/processed_ratings.txt data/space.model data/corrected_ratings_corpus.txt
        ;;
    soy_tokenize)
        echo "soynlp, LTokenizing..."
        python preprocess/unsupervised_nlputils.py compute_soy_word_score data/corrected_ratings_corpus.txt data/soyword.model
        python preprocess/unsupervised_nlputils.py soy_tokenize data/corrected_ratings_corpus.txt data/soyword.model data/tokenized_corpus_soynlp.txt
        ;;
    komoran_tokenize)
        echo "komoran, tokenizing..."
        python preprocess/supervised_nlputils.py komoran data/corpus.txt data/tokenized_corpus_komoran.txt
        ;;
    okt_tokenize)
        echo "okt, tokenizing..."
        python preprocess/supervised_nlputils.py okt data/corpus.txt data/tokenized_corpus_okt.txt
        ;;
    mecab_tokenize)
        echo "mecab, tokenizing..."
        python preprocess/supervised_nlputils.py mecab data/corpus.txt data/tokenized_corpus_mecab.txt
        ;;
    hannanum_tokenize)
        echo "hannanum, tokenizing..."
        python preprocess/supervised_nlputils.py hannanum data/corpus.txt data/tokenized_corpus_hannanum.txt
        ;;
    khai_tokenize)
        echo "khai, tokenizing..."
        python preprocess/supervised_nlputils.py khai data/corpus.txt data/tokenized_corpus_khai.txt
        ;;
    sentencepiece)
        echo "processing sentencepiece..."
        spm_train --input=data/corpus.txt --model_prefix=sentpiece --vocab_size=10000
        mv sentpiece.model data
        mv sentpiece.vocab data
        ;;
esac
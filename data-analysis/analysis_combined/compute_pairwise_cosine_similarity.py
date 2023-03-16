import pandas as pd
import string
import numpy as np
from collections import Counter
import nltk
from nltk.stem import WordNetLemmatizer
from nltk.corpus import wordnet
import  itertools
import math
#nltk.download('averaged_perceptron_tagger')
#nltk.download('wordnet') #uncomment if wordnet is not already downloaded
lemmatiser = WordNetLemmatizer()

#function for creating lemmas/ types
def make_singular(response): #lemmatize nouns. If the repsonse has multiple words, lemmatize just the last word
    response = response.split(' ')
    singular = lemmatiser.lemmatize(response[-1], pos="n")
    if len(response)==1:
        return singular
    else:
        return ' '.join((' '.join(response[0:-1]),singular))
    
def get_wordnet_pos(treebank_tag):

    if treebank_tag.startswith('J'):
        return wordnet.ADJ
    elif treebank_tag.startswith('V'):
        return wordnet.VERB
    elif treebank_tag.startswith('N'):
        return wordnet.NOUN
    elif treebank_tag.startswith('R'):
        return wordnet.ADV
    else:
        return ''
    
    
def lemmatize_pos(response): #lemmatize responses
    response = response.split(' ')
    pos_tags = nltk.pos_tag(response)
    lemma_list=[]
    for i in range(len(response)):
        wordnet_pos=get_wordnet_pos(pos_tags[i][1])
        if wordnet_pos == '':
            lemma_list.append(lemmatiser.lemmatize(response[i]))
        else:
            lemma_list.append(lemmatiser.lemmatize(response[i], pos=wordnet_pos))
    return lemma_list
    
#define function for computing cosine similarity based on counter
def counter_cosine_similarity(c1, c2):
    terms = set(c1).union(c2)
    dotprod = sum(c1.get(k, 0) * c2.get(k, 0) for k in terms)
    magA = math.sqrt(sum(c1.get(k, 0)**2 for k in terms))
    magB = math.sqrt(sum(c2.get(k, 0)**2 for k in terms))
    return dotprod / (magA * magB)


#read in data set
d = pd.read_csv("../data/combined/emogo-combined-image-norms.csv")
#d = pd.read_csv("test.csv") #test data set
#check out the data (first 10 rows)
d.loc[range(10),]

#array of unique category names
categoryNames=np.unique(d["stimulus"])

pairList=list(itertools.combinations(categoryNames,2))

item_list=[]
word_cosine_sim_list=[]
lemma_cosine_sim_list=[]
response_cosine_sim_list=[]
distance_list=[]

for (category1,category2) in pairList:
    print (category1,category2)
    
    #set up list of responses for each category
    wordListResponse_1=[]
    lemmaListResponse_1=[]
    responseLengthList_1=[]
    completeWordList_1=[]
    completeLemmaList_1=[]
    responseList_1=[]
    
    #loop through each response for that category
    for response in d.loc[d["stimulus"]==category1,"response_cleaned"]:
        #break response into a list of unique words while stripping punctuation
        #look up list comprehension in python to try to break down what's going on here
        #I first remove any punctuation/ unusual characters from the response (except apostrophes)
        chars_to_remove = '!"#$%&\()*+,-./:;<=>?@[\\]^_`{|}~' #string.punctuation potentially messes with contractions
        response_punctuation_cleaned=" ".join([y.translate(string.maketrans("",""), chars_to_remove) for y in str(response).lower().split(" ") if (y != "") & (y!=".")])
        #now tokenize
        curWordList = nltk.word_tokenize(response_punctuation_cleaned) #tokenize
        curLemmaList=[lemmatize_pos(x) for x in curWordList]
        #flatten list
        curLemmaList=[y for x in curLemmaList for y in x]
        
        #add to list of word response lists
        wordListResponse_1.append(curWordList)
        lemmaListResponse_1.append(curLemmaList)
        
        
        #add to list tracking the number of words in each response
        responseLengthList_1.append(len(curWordList))
        
        #list of all individual word responses
        completeWordList_1 = completeWordList_1 + curWordList
        completeLemmaList_1 = completeLemmaList_1 + curLemmaList
        
        responseList_1.append(".".join(curWordList))
    
    #set up list of responses for each category
    wordListResponse_2=[]
    lemmaListResponse_2=[]
    responseLengthList_2=[]
    completeWordList_2=[]
    completeLemmaList_2=[]
    responseList_2=[]
    
    #loop through each response for that category
    for response in d.loc[d["stimulus"]==category2,"response_cleaned"]:
        #break response into a list of unique words while stripping punctuation
        #look up list comprehension in python to try to break down what's going on here
        #I first remove any punctuation/ unusual characters from the response (except apostrophes)
        chars_to_remove = '!"#$%&\()*+,-./:;<=>?@[\\]^_`{|}~' #string.punctuation potentially messes with contractions
        response_punctuation_cleaned=" ".join([y.translate(string.maketrans("",""), chars_to_remove) for y in str(response).lower().split(" ") if (y != "") & (y!=".")])
        #now tokenize
        curWordList = nltk.word_tokenize(response_punctuation_cleaned) #tokenize
        curLemmaList=[lemmatize_pos(x) for x in curWordList]
        #flatten list
        curLemmaList=[y for x in curLemmaList for y in x]
        
        #add to list of word response lists
        wordListResponse_2.append(curWordList)
        lemmaListResponse_2.append(curLemmaList)
        
        
        #add to list tracking the number of words in each response
        responseLengthList_2.append(len(curWordList))
        
        #list of all individual word responses
        completeWordList_2 = completeWordList_2 + curWordList
        completeLemmaList_2 = completeLemmaList_2 + curLemmaList
        
        responseList_2.append(".".join(curWordList))
        
    #cosine similarity computations
    word_cosine_sim=counter_cosine_similarity(Counter(completeWordList_1), Counter(completeWordList_2))
    lemma_cosine_sim=counter_cosine_similarity(Counter(completeLemmaList_1), Counter(completeLemmaList_2))
    response_cosine_sim=counter_cosine_similarity(Counter(responseList_1), Counter(responseList_2))
    
    alphabet_category1 = min(category1,category2)
    alphabet_category2 = max(category1,category2)
    
    item_list.append(alphabet_category1+"_"+alphabet_category2)
    word_cosine_sim_list.append(word_cosine_sim)
    lemma_cosine_sim_list.append(lemma_cosine_sim)
    response_cosine_sim_list.append(response_cosine_sim)

#put everything in a data frame
df = pd.DataFrame({'image_pair': item_list,'word_cosine_sim': word_cosine_sim_list, 'lemma_cosine_sim': lemma_cosine_sim_list, 'response_cosine_sim': response_cosine_sim_list})
colNames=['image_pair', 'word_cosine_sim', 'lemma_cosine_sim', 'response_cosine_sim']
#reorder dataframe columns
df=df[colNames]
#write to csv
df.to_csv('../data/combined/emogo-combined-cosine-similarity-image-pairs.csv',index=False)

# -*- coding: utf-8 -*-
"""
Created on Fri Jan 22 16:23:34 2021

@author: Tom
"""

import pickle, csv, math, xml
import pandas as pd
import xml.etree.ElementTree as ET
from nltk.tokenize import word_tokenize

# load table of contents from delper request for Bami Goreng, Klappertaart (so far)
toc = pd.read_csv("40/TableOfContents.csv")

#create new dataframe to hold info about actual pages of interest (toc has only link to full newspaper)
# pages_with_dishes
# will create first the separate column arrays and at the end put together as a df
# columns
# the url should match the structure of the one in recipe web
np_title = []
date = []
title = []
a_type = []
dish = []
url = []
rid = []
txt = []
txt_path = []

dishes = ['klappertaart', 'bami', 'nasi', 'goreng', 'nassi']
folders = [65, 66, 67, 71, 72]

# loop through table of contents, open newspaper xml, open each article text file, search for the occurrence of 3 dishes
# mark entries according to xml tag 'dc:subject'

for i, row in toc.iterrows():
    xml_id = row['OAIPMHI']
    xml_path = f"{xml_id.replace(':', '_')}.xml"

    tree = ET.parse(f"40/{xml_path}")
    root = tree.getroot()
    
    # Get the date and title of the newspaper already
    year_e = row['Date']
    np_title_e = row['Title']
    
    for elem in root:
        
        # Need to find date, newspaper name
        for child in elem:
            for a in child:
                for b in a:
                    for c in b:
                        for d in c:
                            a_type_e = ''
                            title_e = ''
                            rid_e = ''
                            url_e = ''
                            
                            for tags in d:
                                
                                try:
                                    tag = tags.tag.split("}")[1]
                                    content = tags.text
                                    
                                    if tag == 'subject':
                                        a_type_e = content
                                        
                                    elif tag == 'title' :
                                        if type(content) == str:
                                            title_e = content
                                        else:
                                            title_e = "Empty"
                                        
                                    elif tag == 'recordIdentifier':
                                        rid_e = content
                                        
                                    elif tag == 'identifier':
                                        url_e = content
                                    
                                    
                                except:
                                    pass
                                
                            #print(a_type_e, title_e, rid_e, url_e)
                            if len(a_type_e) > 0 and len(title_e)>0 and len(rid_e)>0 and len(url_e)>0:
                                #print(a_type_e, '\n', title_e, '\n', rid_e, '\n', url_e)
                                dish_e = []
                                urlparts = url_e.split('=')[1].split(':')
                                ridparts = rid_e.split(':')
                                txt_e = []
                                
                                for num in folders:
                                    text_path_e = f"40/Resources{num}/{urlparts[0]}/{urlparts[1]}/text/{ridparts[0].upper()}_{ridparts[1]}_{ridparts[-1][1:]}_text.xml"
                                    try:
                                        with open(text_path_e, 'r', encoding='UTF-8') as file:
                                            #search for dishes
                                            for num, line in enumerate(file, start=1):
                                                for dis in dishes:
                                                    linex = word_tokenize(line.lower())
                                                    if dis in linex and dis not in dish_e:
                                                        dish_e.append(dis)
                                                        txt_e[len(txt_e):] = linex
                                                        #input()
                                        break
                                    except:
                                        pass
                                
                                if len(dish_e)>0:
                                    #print(len(dish_e))
                                    np_title.append(np_title_e)
                                    date.append(year_e)
                                    title.append(title_e)
                                    a_type.append(a_type_e)
                                    dish.append(dish_e)
                                    url.append(url_e)
                                    rid.append(rid_e)
                                    txt.append(txt_e)
                                    txt_path.append(text_path_e)
                                    

d = {'np_title':np_title, 'date':date, 'title':title, 'article_type':a_type, 'dish':dish, 'url':url, 'ressource_id':rid, 'text':txt, "text_path":txt_path}
df = pd.DataFrame(data=d)

df.to_csv('final_dish_database.csv')

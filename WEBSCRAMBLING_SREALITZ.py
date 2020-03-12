#!/usr/bin/env python
# coding: utf-8

# In[89]:


import requests
import pandas as pd
from pandas.io.json import json_normalize


a = []
numberOfPages = 80
for page in range(numberOfPages + 1):
    url = "https://www.sreality.cz/api/cs/v2/estates?category_main_cb=1&category_type_cb=1&locality_region_id=10&page="+str(page)+"&per_page=40&tms=1583500044717"
    print(url)
    resp = requests.get(url)
    a.append(resp.json())


a[0]['_embedded']["estates"]


# In[90]:


frames = []

for idx in range(len(a)):
    for estate in (a[idx]["_embedded"]["estates"]):
        frames.append(json_normalize(estate))

df_estates = pd.concat(frames)
df_estates = pd.DataFrame(df_estates)
#df_estates.info()


# In[91]:


df_estates = df_estates.drop(['_embedded.company._links.self.href',
       '_embedded.company._links.self.profile', '_embedded.company.address',
       '_embedded.company.allow_calculator', '_embedded.company.ask.addr_city',
       '_embedded.company.ask.addr_house_num',
       '_embedded.company.ask.addr_street', '_embedded.company.ask.addr_zip',
       '_embedded.company.ask.address', '_embedded.company.ask.description',
       '_embedded.company.ask.email', '_embedded.company.ask.emails',
       '_embedded.company.ask.firmy_review_url',
       '_embedded.company.ask.is_paid', '_embedded.company.ask.offers',
       '_embedded.company.ask.opening_time_additional_info',
       '_embedded.company.ask.opening_time_description',
                             '_embedded.company.ask.opening_time_next_week',
       '_embedded.company.ask.opening_time_st',
       '_embedded.company.ask.opening_time_today',
       '_embedded.company.ask.opening_time_today_date',
       '_embedded.company.ask.opening_time_visible',
       '_embedded.company.ask.partners', '_embedded.company.ask.phones',
       '_embedded.company.ask.photos_premise_url',
       '_embedded.company.ask.photos_url', '_embedded.company.ask.pie',
       '_embedded.company.ask.review_count',
       '_embedded.company.ask.reviews._links.self.href',
       '_embedded.company.ask.reviews._links.self.profile',
       '_embedded.company.ask.reviews.reviews',
       '_embedded.company.ask.reviews.reviews_count',
       '_embedded.company.ask.stars', '_embedded.company.ask_id',
                             '_embedded.company.company_id', '_embedded.company.company_paid_firmy',
       '_embedded.company.company_subject_id', '_embedded.company.description',
       '_embedded.company.email', '_embedded.company.ico',
       '_embedded.company.id', '_embedded.company.locality.lat',
       '_embedded.company.locality.lon', '_embedded.company.logo',
       '_embedded.company.logo_small', '_embedded.company.name',
       '_embedded.company.phones', '_embedded.company.retargeting_id',
       '_embedded.company.seznam_naplno', '_embedded.company.url',
       '_embedded.company.www', '_embedded.company.www_visible',
       '_embedded.favourite._links.self.href',
       '_embedded.favourite._links.self.profile',
       '_embedded.favourite._links.self.title',
                             '_embedded.favourite.is_favourite', '_embedded.note._links.self.href',
       '_embedded.note._links.self.profile',
       '_embedded.note._links.self.title', '_embedded.note.has_note',
       '_embedded.note.note', '_links.dynamicDown', '_links.dynamicUp',
       '_links.image_middle2', '_links.images', '_links.iterator.href',
       '_links.self.href', 'attractive_offer', 'auctionPrice', 'category'], axis = 1)

df_estates.columns


# In[92]:


df = df_estates[['gps.lat', 'gps.lon', 'has_floor_plan', 'has_matterport_url',
       'has_panorama', 'has_video', 'hash_id', 'is_auction', 'labels',
       'labelsAll', 'labelsReleased', 'locality', 'name', 'new', 'paid_logo',
       'price', 'price_czk.name', 'price_czk.unit', 'price_czk.value_raw',
       'region_tip', 'rus', 'seo.category_main_cb', 'seo.category_sub_cb',
       'seo.category_type_cb', 'seo.locality', 'type']]


# In[93]:


#df.head()
df.shape


# In[ ]:


print(df.head())


# In[82]:


df.to_csv("C:/Users/petr7/Desktop/pragueflats.csv", sep = ";")


# In[ ]:





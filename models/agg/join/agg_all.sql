SELECT 
date, 
coalesce(a.url, b.url) url,
coalesce(a.client, b.client) client,
sitemap,
case when sitemap is not null then 'yes' else 'no' end as in_sitemap,
found_at_sitemap,
page_type,
case when page_type in ('info') then 'pageviews'
	when page_type in ('homepage', 'lead_generation', 'article', 'blog_category') then 'revenue'
	when page_type like 'product%' then 'sales'
	else 'traffic' end as page_objective,
rank() over (PARTITION BY page_type ORDER BY sessions_30d desc) as page_type_rank,
domain,
url_stripped,
canonical_url,
canonical_url_stripped,
canonical_status,
urls_to_canonical,
first_subfolder,
first_subfolder_http_status,
sum(sessions_30d) OVER (PARTITION BY first_subfolder) first_subfolder_sessions_30d,
sum(pageviews_30d) OVER (PARTITION BY first_subfolder) first_subfolder_pageviews_30d,
second_subfolder,
second_subfolder_http_status,
sum(sessions_30d) OVER (PARTITION BY second_subfolder) second_subfolder_sessions_30d,
sum(pageviews_30d) OVER (PARTITION BY second_subfolder) second_subfolder_pageviews_30d,
last_subfolder,
last_subfolder_http_status,
sum(sessions_30d) OVER (PARTITION BY last_subfolder) last_subfolder_sessions_30d,
sum(pageviews_30d) OVER (PARTITION BY last_subfolder) last_subfolder_pageviews_30d,
last_subfolder_canonical,
crawl_datetime,
http_status_code,
level,
schema_type,
header_content_type,
word_count, 
page_title,
case when regexp_contains(page_title, gsc_top_keyword_90d) then 1
	when ( gsc_top_keyword_90d is not null or gsc_top_keyword_90d != '' ) then 0 else 2 end as title_contains_top_keyword,
page_title_length,
description,
case when regexp_contains(description, gsc_top_keyword_90d) then 1 
	when ( gsc_top_keyword_90d is not null or gsc_top_keyword_90d != '' ) then 0 else 2 end as description_contains_top_keyword,
description_length,
indexable,
robots_noindex,
is_self_canonical,
backlink_count,
backlink_domain_count,
redirected_to_url,
found_at_url,
rel_next_url,
rel_prev_url,
links_in_count,
links_out_count,
external_links_count,
internal_links_count,
flag_paginated,
case when regexp_contains(coalesce(a.url, b.url), r'\d') then 1 else 0 end as url_contains_digit,
h1_tag,
h2_tag,
redirect_chain,
redirected_to_status_code,
is_redirect_loop,
duplicate_page,
duplicate_page_count,
duplicate_body,
duplicate_body_count,
sessions_30d,
revenue_30d,
transactions_30d,
pageviews_30d,
#case when sessions_30d > 0 then revenue_30d/sessions_30d else null end as lead_conversion_rate_30d,
case when sessions_30d > 0 then transactions_30d/sessions_30d else null end as transaction_conversion_rate_30d,
#PERCENTILE_DISC(case when sessions_30d > 0 then revenue_30d/sessions_30d else null end, 0.5 IGNORE NULLS) OVER (PARTITION BY http_status_code) AS med_lead_conversion_rate_30d,
PERCENTILE_DISC(case when sessions_30d > 0 then transactions_30d/sessions_30d else null end, 0.5 IGNORE NULLS) OVER (PARTITION BY http_status_code) AS med_transaction_conversion_rate_30d,
sessions_mom,
revenue_mom,
transactions_mom,
pageviews_mom,
case when sessions_mom > 0 then (sessions_30d-sessions_mom)/sessions_mom else null end sessions_mom_pct,
case when revenue_mom > 0 then (revenue_30d-revenue_mom)/revenue_mom else null end revenue_mom_pct,
case when transactions_mom > 0 then (transactions_30d-transactions_mom)/transactions_mom else null end transactions_mom_pct,
sessions_yoy,
revenue_yoy,
transactions_yoy,
pageviews_yoy,
case when sessions_yoy > 0 then (sessions_30d-sessions_yoy)/sessions_yoy else null end sessions_yoy_pct,
case when revenue_yoy > 0 then (revenue_30d-revenue_yoy)/revenue_yoy else null end revenue_yoy_pct,
case when transactions_yoy > 0 then (transactions_30d-transactions_yoy)/transactions_yoy else null end transactions_yoy_pct,
case when sessions_30d > sessions_mom then 'yes' else 'no' end as gaining_traffic_mom,
case when sessions_30d > sessions_yoy then 'yes' else 'no' end as gaining_traffic_yoy,
ref_domain_count,
PERCENTILE_DISC(ref_domain_count, 0.5 IGNORE NULLS) OVER (PARTITION BY http_status_code) AS med_ref_domain_count,
avg_trust_flow,
avg_citation_flow,
gsc_keyword_count_90d,
gsc_impressions_90d,
gsc_clicks_90d,	
gsc_ctr_90d,
gsc_top_keyword_90d,
gsc_top_url_for_keyword_90d,
gsc_top_url_impressions_for_keyword_90d,
gsc_top_keyword_impressions_90d, 
gsc_top_keyword_clicks_90d, 
gsc_top_keyword_ctr_90d,
semrush_keyword_count,
semrush_total_cpc,
semrush_total_search_volume,
semrush_top_keyword_vol,
semrush_top_keyword_vol_vol, 
semrush_top_keyword_vol_cpc, 
semrush_top_keyword_cpc,
semrush_top_keyword_cpc_vol, 
semrush_top_keyword_cpc_cpc
FROM 
  {{ref('agg_stats_client')}} a
FULL OUTER JOIN {{ref('agg_indicative')}} b
ON ( a.url = b.url
	and a.client = b.client )
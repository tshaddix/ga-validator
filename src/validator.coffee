dimensions = []

metrics = []

metrics_regex = null

dimensions_regex = null

#
# Adds a metric to internal storage
# 	@param {string} metric value
# 	@param {string} human readable name
# 	@param {string} regex expression for matching, null will match full value
# 	@param {string} section of metric
#
addMetric = (met, name, regex=met)->
	metrics.push {
		value : met
		name : name
		regex : new RegExp "^#{regex}$"
	}

#
# Adds a dimension to internal storage
# 	@param {string} dimension value
# 	@param {string} human readable name
# 	@param {string} regex expression for matching, null will match full value
# 	@param {string} section of dimension
#
addDimension = (dim, name, regex=dim)->
	dimensions.push {
		value : dim
		name : name
		regex : new RegExp "^#{regex}$"
	}

#
# Gets the dimension which matches param
# 	@param {string} dimension value to match
# 	@returns {object} dimension if found or null
#
getDimension = (dim)->
	return dimension for dimension in dimensions when dimension.regex.test dim
	return null

#
# Gets the metric which matches param
# 	@param {string} metric value to match
# 	@returns {object} metric if found or null
#
getMetric = (met)->
	return metric for metric in metrics when metric.regex.test met
	return null

#
# Checks wether a dimension value is valid
# 	@param {string} dimension value
# 	@returns {boolean} true if matched
#
checkDimension = (dim)->
	return dimensions_regex.test dim

#
# Checks wether a metric value is valid
# 	@param {string} metric value
# 	@returns {boolean} true if matched
#
checkMetric = (met)->
	return metrics_regex.test met

#
# Checks wether a sort is valid
# 	@param {string} sort value
#	@returns {boolean} true if valid
#
checkSort = (sort)->
	if sort.length is 0 then return false

	check = if sort[0] is '-' then sort.replace /^-/, '' else sort

	return checkMetric(check) or checkDimension(check)

#
# Checks whether string is valid segment
# 	@param {string} seg valie
# 	@return {boolean} true if valid
#
checkSegment = (seg)->
	is_dynamic = new RegExp('^dynamic::').test seg

	if is_dynamic then return checkFilter seg.replace /^dynamic::/, ''
	else return new RegExp('^gaid::-?[0-9]+$').test seg

#
# Checks whether filter is valid format
# 	@param {string} filter value
# 	@return {boolean} true if valid
#
checkFilter = (filter)->
	# AND combinations are always valid
	# so we can break them initially to lighten load
	and_exps = filter.split ';'

	#loop through all expressions
	for and_exp in and_exps

		#split into OR expressions
		or_exps = and_exp.split ','

		exp_type = null

		#loop through or expressions
		for or_exp in or_exps
			if not exp_type?
				ga_name = or_exp.split(new RegExp('==|!=|=@|!@|=~|!~|!=|>|<|>=|<=', 'g'), 2)[0]

				if checkMetric(ga_name)
					exp_type = 'metric'
				else if checkDimension(ga_name)
					exp_type = 'dimension'
				else
					return false


			components = if exp_type is 'metric' then components = or_exp.split new RegExp('==|!=|>|<|>=|<=', 'g'), 2 else or_exp.split new RegExp('==|!=|=@|!@|=~|!~', 'g'), 2

			#if components.length is 1 then return false

			if exp_type is 'metric'
				if not checkMetric(components[0]) or not /^[0-9]+$/.test components[1] then return false
			else
				if not checkDimension(components[0]) then return false

	return true

buildRegex = ->
	mreg = ''

	for metric, i in metrics
		if i isnt 0 then mreg += '|'
		mreg += metric.regex.source

	metrics_regex = new RegExp mreg

	dreg = ''

	for dim, i in dimensions
		if i isnt 0 then dreg += '|'
		dreg += dim.regex.source

	dimensions_regex = new RegExp dreg

#User
addDimension 'ga:userType', 'User Type'
addDimension 'ga:sessionCount', 'Count of Sessions'
addDimension 'ga:daysSinceLastSession', 'Days Since Last Session'
addDimension 'ga:userDefinedValue', 'User Defined Value'

addMetric 'ga:users', 'Users'
addMetric 'ga:newUsers', 'New Users'
addMetric 'ga:percentNewSessions', 'Percent New Sessions'

#Session
addDimension 'ga:sessionDurationBucket', 'Session Duration'

addMetric 'ga:sessions', 'Sessions'
addMetric 'ga:bounces', 'Bounces'
addMetric 'ga:sessionDuration', 'Session Duration'
addMetric 'ga:bounceRate', 'Bounce Rate'
addMetric 'ga:avgSessionDuration', 'Avg. Session Duration'

#Traffic Sources
addDimension 'ga:referralPath', 'Referral Path'
addDimension 'ga:fullReferrer', 'Full Referrer'
addDimension 'ga:campaign', 'Campaign'
addDimension 'ga:source', 'Source'
addDimension 'ga:medium', 'Medium'
addDimension 'ga:sourceMedium', 'Source / Medium'
addDimension 'ga:keyword', 'Keyword'
addDimension 'ga:adContent', 'Ad Content'
addDimension 'ga:socialNetwork', 'Social Network'
addDimension 'ga:hasSocialSourceReferral', 'Has Social Source Referral'

addMetric 'ga:organicSearches', 'Organic Searches'

#AdWords
addDimension 'ga:adGroup', 'Ad Group'
addDimension 'ga:adSlot', 'Ad Slot'
addDimension 'ga:adSlotPosition', 'Ad Slot Position'
addDimension 'ga:adDistributionNetwork', 'Ad Distribution Network'
addDimension 'ga:adMatchType', 'Query Match Type'
addDimension 'ga:adKeywordMatchType', 'Keyword Match Type'
addDimension 'ga:adMatchedQuery', 'Matched Search Query'
addDimension 'ga:adPlacementDomain', 'Placement Domain'
addDimension 'ga:adPlacementUrl', 'Placement URL'
addDimension 'ga:adFormat', 'Ad Format'
addDimension 'ga:adTargetingType', 'Targeting Type'
addDimension 'ga:adTargetingOption', 'Placement Type'
addDimension 'ga:adDisplayUrl', 'Display URL'
addDimension 'ga:adDestinationUrl', 'Destination URL'
addDimension 'ga:adwordsCustomerID', 'AdWords Customer ID'
addDimension 'ga:adwordsCampaignID', 'AdWords Campaign ID'
addDimension 'ga:adwordsAdGroupID', 'AdWords Ad Group ID'
addDimension 'ga:adwordsCreativeID', 'AdWords Creative ID'
addDimension 'ga:adwordsCriteriaID', 'AdWords Criteria ID'
addDimension 'ga:isTrueViewVideoAd', 'TrueView Video Ad'

addMetric 'ga:impressions', 'Impressions'
addMetric 'ga:adClicks', 'Ad Clicks'
addMetric 'ga:adCost', 'Ad Cost'
addMetric 'ga:CPM', 'Cost Per Thousand Impressions'
addMetric 'ga:CPC', 'Cost to Advertiser Per Click'
addMetric 'ga:CTR', 'Click Through Rate'
addMetric 'ga:costPerTransaction', 'Cost per Transaction'
addMetric 'ga:costPerGoalConversion', 'Cost per Goal Conversion'
addMetric 'ga:costPerConversion', 'Cost per Conversion'
addMetric 'ga:RPC', 'Revenue Per Click'
addMetric 'ga:ROI', 'Returns On Investment'
addMetric 'ga:margin', 'Margin'

#Goal Conversions
addDimension 'ga:goalCompletionLocation', 'Goal Completion Location'
addDimension 'ga:goalPreviousStep1', 'Goal Previous Step - 1'
addDimension 'ga:goalPreviousStep2', 'Goal Previous Step - 2'
addDimension 'ga:goalPreviousStep3', 'Goal Previous Step - 3'

addMetric 'ga:goalXXStarts', 'Goal XX Starts'
addMetric 'ga:goalStartsAll', 'Goal Starts'
addMetric 'ga:goalXXCompletions', 'Goal XX Completions'
addMetric 'ga:goalCompletionsAll', 'Goal Completions'
addMetric 'ga:goalXXValue', 'Goal XX Value'
addMetric 'ga:goalValueAll', 'Goal Value'
addMetric 'ga:goalValuePerSession', 'Per Session Goal Value'
addMetric 'ga:goalXXConversionRate', 'Goal XX Conversion Rate'
addMetric 'ga:goalConversionRateAll', 'Goal Conversion Rate'
addMetric 'ga:goalXXAbandons', 'Goal XX Abandoned Funnels'
addMetric 'ga:goalAbandonsAll', 'Abandoned Funnels'
addMetric 'ga:goalXXAbandonRate', 'Goal XX Abandonment Rate'
addMetric 'ga:goalAbandonRateAll', 'Total Abandonment Rate'

#Platform or Device
addDimension 'ga:browser', 'Browser'
addDimension 'ga:browserVersion', 'Browser Version'
addDimension 'ga:operatingSystem', 'Operating System'
addDimension 'ga:operatingSystemVersion', 'Operating System Version'
addDimension 'ga:mobileDeviceBranding', 'Mobile Device Branding'
addDimension 'ga:mobileDeviceModel', 'Mobile Device Model'
addDimension 'ga:mobileInputSelector', 'Mobile Input Selector'
addDimension 'ga:mobileDeviceInfo', 'Mobile Device Info'
addDimension 'ga:mobileDeviceMarketingName', 'Mobile Device Marketing Name'
addDimension 'ga:deviceCategory', 'Device Category'

#Geo Network
addDimension 'ga:continent', 'Continent'
addDimension 'ga:subContinent', 'Sub Continent Region'
addDimension 'ga:country', 'Country / Territory'
addDimension 'ga:region', 'Region'
addDimension 'ga:metro', 'Metro'
addDimension 'ga:city', 'City'
addDimension 'ga:latitude', 'Latitude'
addDimension 'ga:longitude', 'Longitude'
addDimension 'ga:networkDomain', 'Network Domain'
addDimension 'ga:networkLocation', 'Service Provider'

#System
addDimension 'ga:flashVersion', 'Flash Version'
addDimension 'ga:javaEnabled', 'Java Support'
addDimension 'ga:language', 'Language'
addDimension 'ga:screenColors', 'Screen Colors'
addDimension 'ga:sourcePropertyDisplayName', 'Source Property Display Name'
addDimension 'ga:sourcePropertyTrackingId', 'Source Property Tracking ID'
addDimension 'ga:screenResolution', 'Screen Resolution'

#Social Activities
addDimension 'ga:socialActivityEndorsingUrl', 'Endorsing URL'
addDimension 'ga:socialActivityDisplayName', 'Display Name'
addDimension 'ga:socialActivityPost', 'Social Activity Post'
addDimension 'ga:socialActivityTimestamp', 'Social Activity Timestamp'
addDimension 'ga:socialActivityUserHandle', 'Social User Handle'
addDimension 'ga:socialActivityUserPhotoUrl', 'User Photo URL'
addDimension 'ga:socialActivityUserProfileUrl', 'User Profile URL'
addDimension 'ga:socialActivityContentUrl', 'Shared URL'
addDimension 'ga:socialActivityTagsSummary', 'Social Tags Summary'
addDimension 'ga:socialActivityAction', 'Originating Social Action'
addDimension 'ga:socialActivityNetworkAction', 'Social Network and Action'

addMetric 'ga:socialActivities', 'Data Hub Activities'

#Page Tracking
addDimension 'ga:hostname', 'Hostname'
addDimension 'ga:pagePath', 'Page'
addDimension 'ga:pagePathLevel1', 'Page path level 1'
addDimension 'ga:pagePathLevel2', 'Page path level 2'
addDimension 'ga:pagePathLevel3', 'Page path level 3'
addDimension 'ga:pagePathLevel4', 'Page path level 4'
addDimension 'ga:pageTitle', 'Page Title'
addDimension 'ga:landingPagePath', 'Landing Page'
addDimension 'ga:secondPagePath', 'Second Page'
addDimension 'ga:exitPagePath', 'Exit Page'
addDimension 'ga:previousPagePath', 'Previous Page Path'
addDimension 'ga:nextPagePath', 'Next Page Path'
addDimension 'ga:pageDepth', 'Page Depth'

addMetric 'ga:pageValue', 'Page Value'
addMetric 'ga:entrances', 'Entrances'
addMetric 'ga:pageviews', 'Pageviews'
addMetric 'ga:uniquePageviews', 'Unique Pageviews'
addMetric 'ga:timeOnPage', 'Time on Page'
addMetric 'ga:exits', 'Exits'
addMetric 'ga:entranceRate', 'Entrances / Pageviews'
addMetric 'ga:pageviewsPerSession', 'Pages / Session'
addMetric 'ga:avgTimeOnPage', 'Avg. Time on Page'
addMetric 'ga:exitRate', '% Exit'

#Content Grouping
addDimension 'ga:landingContentGroupXX', 'Landing Page Group XX'
addDimension 'ga:previousContentGroupXX', 'Previous Page Group XX'
addDimension 'ga:contentGroupXX', 'Page Group XX'
addDimension 'ga:nextContentGroupXX', 'Next Page Group XX'

addMetric 'ga:contentGroupUniqueViewsXX', 'Unique Views'

#Internal Search
addDimension 'ga:searchUsed', 'Site Search Status'
addDimension 'ga:searchKeyword', 'Search Term'
addDimension 'ga:searchKeywordRefinement', 'Refined Keyword'
addDimension 'ga:searchCategory', 'Site Search Category'
addDimension 'ga:searchStartPage', 'Start Page'
addDimension 'ga:searchDestinationPage', 'Destination Page'

addMetric 'ga:searchResultViews', 'Results Pageviews'
addMetric 'ga:searchUniques', 'Total Unique Searches'
addMetric 'ga:searchSessions', 'Sessions with Search'
addMetric 'ga:searchDepth', 'Search Depth'
addMetric 'ga:searchRefinements', 'Search Refinements'
addMetric 'ga:searchDuration', 'Time after Search'
addMetric 'ga:searchExits', 'Search Exits'
addMetric 'ga:avgSearchResultViews', 'Results Pageviews / Search'
addMetric 'ga:percentSessionsWithSearch', '% Sessions with Search'
addMetric 'ga:avgSearchDepth', 'Average Search Depth'
addMetric 'ga:percentSearchRefinements', '% Search Refinements'
addMetric 'ga:avgSearchDuration', 'Time after Search'
addMetric 'ga:searchExitRate', '% Search Exits'
addMetric 'ga:searchGoalXXConversionRate', 'Site Search Goal XX Conversion Rate'
addMetric 'ga:searchGoalConversionRateAll', 'Site Search Goal Conversion Rate'
addMetric 'ga:goalValueAllPerSearch', 'Per Search Goal Value'

#Site Speed
addMetric 'ga:pageLoadTime', 'Page Load Time (ms)'
addMetric 'ga:pageLoadSample', 'Page Load Sample'
addMetric 'ga:domainLookupTime', 'Domain Lookup Time (ms)'
addMetric 'ga:pageDownloadTime', 'Page Download Time (ms)'
addMetric 'ga:redirectionTime', 'Redirection Time (ms)'
addMetric 'ga:serverConnectionTime', 'Server Connection Time (ms)'
addMetric 'ga:serverResponseTime', 'Server Response Time (ms)'
addMetric 'ga:speedMetricsSample', 'Speed Metrics Sample'
addMetric 'ga:domInteractiveTime', 'Document Interactive Time (ms)'
addMetric 'ga:domContentLoadedTime', 'Document Content Loaded Time (ms)'
addMetric 'ga:domLatencyMetricsSample', 'DOM Latency Metrics Sample'
addMetric 'ga:avgPageLoadTime', 'Avg. Page Load Time (sec)'
addMetric 'ga:avgDomainLookupTime', 'Avg. Domain Lookup Time (sec)'
addMetric 'ga:avgPageDownloadTime', 'Avg. Page Download Time (sec)'
addMetric 'ga:avgRedirectionTime', 'Avg. Redirection Time (sec)'
addMetric 'ga:avgServerConnectionTime', 'Avg. Server Connection Time (sec)'
addMetric 'ga:avgServerResponseTime', 'Avg. Server Response Time (sec)'
addMetric 'ga:avgDomInteractiveTime', 'Avg. Document Interactive Time (sec)'
addMetric 'ga:avgDomContentLoadedTime', 'Avg. Document Content Loaded Time (sec)'

#App Tracking
addDimension 'ga:appInstallerId', 'App Installer ID'
addDimension 'ga:appVersion', 'App Version'
addDimension 'ga:appName', 'App Name'
addDimension 'ga:appId', 'App ID'
addDimension 'ga:screenName', 'Screen Name'
addDimension 'ga:screenDepth', 'Screen Depth'
addDimension 'ga:landingScreenName', 'Landing Screen'
addDimension 'ga:exitScreenName', 'Exit Screen'

addMetric 'ga:screenviews', 'Screen Views'
addMetric 'ga:uniqueScreenviews', 'Unique Screen Views'
addMetric 'ga:timeOnScreen', 'Time on Screen'
addMetric 'ga:avgScreenviewDuration', 'Avg. Time on Screen'
addMetric 'ga:screenviewsPerSession', 'Screens / Session'

#Event Tracking
addDimension 'ga:eventCategory', 'Event Category'
addDimension 'ga:eventAction', 'Event Action'
addDimension 'ga:eventLabel', 'Event Label'

addMetric 'ga:totalEvents', 'Total Events'
addMetric 'ga:uniqueEvents', 'Unique Events'
addMetric 'ga:eventValue', 'Event Value'
addMetric 'ga:sessionsWithEvent', 'Sessions with Event'
addMetric 'ga:avgEventValue', 'Avg. Value'
addMetric 'ga:eventsPerSessionWithEvent', 'Events / Session with Event'

#Ecommerce
addDimension 'ga:transactionId', 'Transaction Id'
addDimension 'ga:affiliation', 'Affiliation'
addDimension 'ga:sessionsToTransaction', 'Sessions to Transaction'
addDimension 'ga:daysToTransaction', 'Days to Transaction'
addDimension 'ga:productSku', 'Product SKU'
addDimension 'ga:productName', 'Product'
addDimension 'ga:productCategory', 'Product Category'
addDimension 'ga:currencyCode', 'Currency Code'
addDimension 'ga:checkoutOptions', 'Checkout Options'
addDimension 'ga:internalPromotionCreative', 'Internal Promotion Creative'
addDimension 'ga:internalPromotionId', 'Internal Promotion ID'
addDimension 'ga:internalPromotionName', 'Internal Promotion Name'
addDimension 'ga:internalPromotionPosition', 'Internal Promotion Position'
addDimension 'ga:orderCouponCode', 'Order Coupon Code'
addDimension 'ga:productBrand', 'Product Brand'
addDimension 'ga:productCategoryHierarchy', 'Product Category (Enhanced Ecommerce)'
addDimension 'ga:productCategoryLevelXX', 'Product Category Level XX'
addDimension 'ga:productCouponCode', 'Product Coupon Code'
addDimension 'ga:productListName', 'Product List Name'
addDimension 'ga:productListPosition', 'Product List Position'
addDimension 'ga:productVariant', 'Product Variant'
addDimension 'ga:shoppingStage', 'Shopping Stage'

addMetric 'ga:transactions', 'Transactions'
addMetric 'ga:transactionRevenue', 'Revenue'
addMetric 'ga:transactionShipping', 'Shipping'
addMetric 'ga:transactionTax', 'Tax'
addMetric 'ga:itemQuantity', 'Quantity'
addMetric 'ga:uniquePurchases', 'Unique Purchases'
addMetric 'ga:itemRevenue', 'Product Revenue'
addMetric 'ga:localTransactionRevenue', 'Local Revenue'
addMetric 'ga:localTransactionShipping', 'Local Shipping'
addMetric 'ga:localTransactionTax', 'Local Tax'
addMetric 'ga:localItemRevenue', 'Local Product Revenue'
addMetric 'ga:buyToDetailRate', 'Buy-to-Detail Rate'
addMetric 'ga:cartToDetailRate', 'Cart-to-Detail Rate'
addMetric 'ga:internalPromotionClicks', 'Internal Promotion Clicks'
addMetric 'ga:internalPromotionViews', 'Internal Promotion Views'
addMetric 'ga:localProductRefundAmount', 'Local Product Refund Amount'
addMetric 'ga:localRefundAmount', 'Local Refund Amount'
addMetric 'ga:productAddsToCart', 'Product Adds To Cart'
addMetric 'ga:productCheckouts', 'Product Checkouts'
addMetric 'ga:productDetailViews', 'Product Detail Views'
addMetric 'ga:productListClicks', 'Product List Clicks'
addMetric 'ga:productListViews', 'Product List Views'
addMetric 'ga:productRefundAmount', 'Product Refund Amount'
addMetric 'ga:productRefunds', 'Product Refunds'
addMetric 'ga:productRemovesFromCart', 'Product Removes From Cart'
addMetric 'ga:quantityAddedToCart', 'Quantity Added To Cart'
addMetric 'ga:quantityCheckedOut', 'Quantity Checked Out'
addMetric 'ga:quantityRefunded', 'Quantity Refunded'
addMetric 'ga:quantityRemovedFromCart', 'Quantity Removed From Cart'
addMetric 'ga:refundAmount', 'Refund Amount'
addMetric 'ga:totalRefunds', 'Refunds'
addMetric 'ga:transactionsPerSession', 'Ecommerce Conversion Rate'
addMetric 'ga:revenuePerTransaction', 'Average Order Value'
addMetric 'ga:transactionRevenuePerSession', 'Per Session Value'
addMetric 'ga:totalValue', 'Total Value'
addMetric 'ga:revenuePerItem', 'Average Price'
addMetric 'ga:itemsPerPurchase', 'Average QTY'
addMetric 'ga:internalPromotionCTR', 'Internal Promotion CTR'
addMetric 'ga:productListCTR', 'Product List CTR'
addMetric 'ga:productRevenuePerPurchase', 'Product Revenue per Purchase'

#Social Interactions
addDimension 'ga:socialInteractionNetwork', 'Social Source'
addDimension 'ga:socialInteractionAction', 'Social Action'
addDimension 'ga:socialInteractionNetworkAction', 'Social Source and Action'
addDimension 'ga:socialInteractionTarget', 'Social Entity'
addDimension 'ga:socialEngagementType', 'Social Type'

addMetric 'ga:socialInteractions', 'Social Actions'
addMetric 'ga:uniqueSocialInteractions', 'Unique Social Actions'
addMetric 'ga:socialInteractionsPerSession', 'Actions Per Social Session'

#User Timings
addDimension 'ga:userTimingCategory', 'Timing Category'
addDimension 'ga:userTimingLabel', 'Timing Label'
addDimension 'ga:userTimingVariable', 'Timing Variable'

addMetric 'ga:userTimingValue', 'User Timing (ms)'
addMetric 'ga:userTimingSample', 'User Timing Sample'
addMetric 'ga:avgUserTimingValue', 'Avg. User Timing (sec)'

#Exceptions
addDimension 'ga:exceptionDescription', 'Exception Description'

addMetric 'ga:exceptions', 'Exceptions'
addMetric 'ga:fatalExceptions', 'Crashes'
addMetric 'ga:exceptionsPerScreenview', 'Exceptions / Screen'
addMetric 'ga:fatalExceptionsPerScreenview', 'Crashes / Screen'

#Content Experiments
addDimension 'ga:experimentId', 'Experiment ID'
addDimension 'ga:experimentVariant', 'Variation'

#Custom Variables or Columns
addDimension 'ga:dimensionXX', 'Custom Dimension XX'
addDimension 'ga:customVarNameXX', 'Custom Variable (Key XX)'
addDimension 'ga:customVarValueXX', 'Custom Variable (Value XX)'

addMetric 'ga:metricXX', 'Custom Metric XX Value'

#Time
addDimension 'ga:date', 'Date'
addDimension 'ga:year', 'Year'
addDimension 'ga:month', 'Month of the year'
addDimension 'ga:week', 'Week of the Year'
addDimension 'ga:day', 'Day of the month'
addDimension 'ga:hour', 'Hour'
addDimension 'ga:minute', 'Minute'
addDimension 'ga:nthMonth', 'Month Index'
addDimension 'ga:nthWeek', 'Week Index'
addDimension 'ga:nthDay', 'Day Index'
addDimension 'ga:nthMinute', 'Minute Index'
addDimension 'ga:dayOfWeek', 'Day of Week'
addDimension 'ga:dayOfWeekName', 'Day of Week Name'
addDimension 'ga:dateHour', 'Hour of Day'
addDimension 'ga:yearMonth', 'Month of Year'
addDimension 'ga:yearWeek', 'Week of Year'
addDimension 'ga:isoWeek', 'ISO Week of the Year'
addDimension 'ga:isoYear', 'ISO Year'
addDimension 'ga:isoYearIsoWeek', 'ISO Week of ISO Year'
addDimension 'ga:nthHour', 'Hour Index'

#Audience
addDimension 'ga:userAgeBracket', 'Age'
addDimension 'ga:userGender', 'Gender'
addDimension 'ga:interestOtherCategory', 'Other Category'
addDimension 'ga:interestAffinityCategory', 'Affinity Category (reach)'
addDimension 'ga:interestInMarketCategory', 'In-Market Segment'

#Adsense
addMetric 'ga:adsenseRevenue', 'AdSense Revenue'
addMetric 'ga:adsenseAdUnitsViewed', 'AdSense Ad Units Viewed'
addMetric 'ga:adsenseAdsViewed', 'AdSense Ads Viewed'
addMetric 'ga:adsenseAdsClicks', 'AdSense Ads Clicked'
addMetric 'ga:adsensePageImpressions', 'AdSense Page Impressions'
addMetric 'ga:adsenseExits', 'AdSense Exits'
addMetric 'ga:adsenseCTR', 'AdSense CTR'
addMetric 'ga:adsenseECPM', 'AdSense eCPM'

#Channel Grouping
addDimension 'ga:channelGrouping', 'Default Channel Grouping'

#Related Products
addDimension 'ga:correlationModelId', 'Correlation Model ID'
addDimension 'ga:queryProductId', 'Queried Product ID'
addDimension 'ga:queryProductName', 'Queried Product Name'
addDimension 'ga:queryProductVariation', 'Queried Product Variation'
addDimension 'ga:relatedProductId', 'Related Product ID'
addDimension 'ga:relatedProductName', 'Related Product Name'
addDimension 'ga:relatedProductVariation', 'Related Product Variation'

addMetric 'ga:correlationScore', 'Correlation Score'
addMetric 'ga:queryProductQuantity', 'Queried Product Quantity'
addMetric 'ga:relatedProductQuantity', 'Related Product Quantity'

#
# Build Regex
#
do buildRegex

#
# Exports
#
exports.metrics = metrics
exports.dimensions = dimensions
exports.getMetric = getMetric
exports.getDimension = getDimension
exports.checkMetric = checkMetric
exports.checkDimension = checkDimension
exports.checkFilter = checkFilter
exports.checkSort = checkSort
exports.checkSegment = checkSegment

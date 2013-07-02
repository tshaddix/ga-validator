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

#Visitor
addMetric 'ga:visitors', 'Visitors'
addMetric 'ga:newVisits', 'New Visits'
addMetric 'ga:percentNewVisits', 'Percent New Visits'

addDimension 'ga:visitorType', 'Visitor Type'
addDimension 'ga:visitCount', 'Visit Count'
addDimension 'ga:daysSinceLastVisit', 'Days Since Last Visit'
addDimension 'ga:userDefinedValue', 'User Defined Value'

#Session
addMetric 'ga:visits', 'Visits'
addMetric 'ga:bounces', 'Bounces'
addMetric 'ga:entranceBounceRate', 'Entrance Bounce Rate'
addMetric 'ga:visitBounceRate', 'Visit Bounce Rate'
addMetric 'ga:timeOnSite', 'Time On Site'
addMetric 'ga:avgTimeOnSite', 'Average Time On Site'

addDimension 'ga:visitLength', 'Visit Length'

#Traffic Sources
addMetric 'ga:organicSearches', 'Organic Searches'

addDimension 'ga:referralPath', 'Referral Path'
addDimension 'ga:campaign', 'Campaign'
addDimension 'ga:source', 'Source'
addDimension 'ga:medium', 'Medium'
addDimension 'ga:keyword', 'Keyword'
addDimension 'ga:adContent', 'Ad Content'
addDimension 'ga:socialNetwork', 'Social Network'
addDimension 'ga:hasSocialSourceReferral', 'Has Social Source Referral'

#AdWords
addMetric 'ga:impressions', 'Impressions'
addMetric 'ga:adClicks', 'Ad Clicks'
addMetric 'ga:adCost', 'Ad Cost'
addMetric 'ga:CPM', 'Cost Per Thousand Impressions'
addMetric 'ga:CPC', 'Cost to Advertiser Per Click'
addMetric 'ga:CTR', 'Click Through Rate'
addMetric 'ga:costPerTransaction', 'Cost Per Transaction'
addMetric 'ga:costPerGoalConversion', 'Cost Per Goal Conversion'
addMetric 'ga:RPC', 'Revenue Per Click'
addMetric 'ga:ROI', 'Returns On Investment'
addMetric 'ga:margin', 'Margin'

addDimension 'ga:adGroup', 'Ad Group'
addDimension 'ga:adSlot', 'Ad Slot'
addDimension 'ga:adSlotPosition', 'Ad Slot Position'
addDimension 'ga:adDistributionNetwork', 'Ad Distribution Network'
addDimension 'ga:adMatchType', 'Ad Match Type'
addDimension 'ga:adMatchedQuery', 'Ad Matched Query'
addDimension 'ga:adPlacementDomain', 'Ad Placement Domain'
addDimension 'ga:adPlacementUrl', 'Ad Placement Url'
addDimension 'ga:adFormat', 'Ad Format'
addDimension 'ga:adTargetingType', 'Ad Targeting Type'
addDimension 'ga:adTargetingOption', 'Ad Targeting Option'
addDimension 'ga:adDisplayUrl', 'Ad Display Url'
addDimension 'ga:adDestinationUrl', 'Ad Destination Url'
addDimension 'ga:adwordsCustomerID', 'Adwords Customer ID'
addDimension 'ga:adwordsCampaignID', 'Adwords Campaign ID'
addDimension 'ga:adwordsAdGroupID', 'Adwords Ad Group ID'
addDimension 'ga:adwordsCreativeID', 'Adwords Creative ID'
addDimension 'ga:adwordsCriteriaID', 'Adwords Criteria ID'

#Goal Conversions
addMetric 'ga:goal(n)Start', 'Goal Start', 'ga:goal([0-9]+)Start'
addMetric 'ga:goalStartsAll', 'All Goal Starts'
addMetric 'ga:goal(n)Completions', 'Goal Completions', 'ga:goal([0-9]+)Completions'
addMetric 'ga:goalCompletionsAll', 'All Goal Completions'
addMetric 'ga:goal(n)Value', 'Goal Value', 'ga:goal([0-9]+)Value'
addMetric 'ga:goalValueAll', 'All Goal Values'
addMetric 'ga:goalValuePerVisit', 'Goal Value Per Visit'
addMetric 'ga:goal(n)ConversionRate', 'Goal Conversion Rate', 'ga:goal([0-9]+)ConversionRate'
addMetric 'ga:goalConversionRateAll', 'All Goal Conversion Rates'
addMetric 'ga:goal(n)Abandons', 'Goal Abandons', 'ga:goal([0-9]+)Abandons'
addMetric 'ga:goalAbandonsAll', 'All Goal Abandons'
addMetric 'ga:goal(n)AbandonRate', 'Goal Abandon Rate', 'ga:goal([0-9]+)AbandonRate'
addMetric 'ga:goalAbandonRateAll', 'All Goals Abandon Rate'

#Platfrom / Device
addDimension 'ga:browser', 'Browser'
addDimension 'ga:browserVersion', 'Browser Version'
addDimension 'ga:operatingSystem', 'Operating System'
addDimension 'ga:operatingSystemVersion', 'Operating System Version'
addDimension 'ga:isMobile', 'Is Mobile'
addDimension 'ga:mobileDeviceBranding', 'Mobile Device Branding'
addDimension 'ga:mobileDeviceModel', 'Mobile Device Model'
addDimension 'ga:mobileInputSelector', 'Mobile Input Selector'
addDimension 'ga:mobileDeviceInfo', 'Mobile Device Info'

#Geo / Network
addDimension 'ga:continent', 'Continent'
addDimension 'ga:subContinent', 'Sub Continent'
addDimension 'ga:country', 'Country'
addDimension 'ga:region', 'Region'
addDimension 'ga:metro', 'Metro'
addDimension 'ga:city', 'City'
addDimension 'ga:latitude', 'Latitude'
addDimension 'ga:longitude', 'Longitude'
addDimension 'ga:networkDomain', 'Network Domain'
addDimension 'ga:networkLocation', 'Network Location'

#System
addDimension 'ga:flashVersion', 'Flash Version'
addDimension 'ga:javaEnabled', 'Java Enabled'
addDimension 'ga:language', 'Language'
addDimension 'ga:screenColors', 'Screen Colors'
addDimension 'ga:screenResolution', 'Screen Resolution'

#Social Activities
addMetric 'ga:socialActivities', 'Social Activities'

addDimension 'ga:socialActivityEndorsingUrl', 'Social Activity Endorsing Url'
addDimension 'ga:socialActivityDisplayName', 'Social Activity Display Name'
addDimension 'ga:socialActivityPost', 'Social Activity Post'
addDimension 'ga:socialActivityTimestamp', 'Social Activity Timestamp'
addDimension 'ga:socialActivityUserHandle', 'Social Activity User Handle'
addDimension 'ga:socialActivityUserPhotoUrl', 'Social Activity User Photo Url'
addDimension 'ga:socialActivityUserProfileUrl', 'Social Activity User Profile Url'
addDimension 'ga:socialActivityContentUrl', 'Social Activity Content Url'
addDimension 'ga:socialActivityTagsSummary', 'Social Activity Tags Summary'
addDimension 'ga:socialActivityAction', 'Social Activity Action'
addDimension 'ga:socialActivityNetworkAction', 'Social Activity Network Action'

#Page Tracking
addMetric 'ga:entrances', 'Entrances'
addMetric 'ga:entraceRate', 'Entrance Rate'
addMetric 'ga:pageviews', 'Page Views'
addMetric 'ga:pageviewsPerVisit', 'Page Views Per Visit'
addMetric 'ga:uniquePageviews', 'Unique Page Views'
addMetric 'ga:timeOnPage', 'Time On Page'
addMetric 'ga:avgTimeOnPage', 'Average Time On Page'
addMetric 'ga:exits', 'Exits'
addMetric 'ga:exitRate', 'Exit Rate'

addDimension 'ga:hostname', 'Hostname'
addDimension 'ga:pagePath', 'Page Path'
addDimension 'ga:pagePathLevel1', 'Page Path Level 1'
addDimension 'ga:pagePathLevel2', 'Page Path Level 2'
addDimension 'ga:pagePathLevel3', 'Page Path Level 3'
addDimension 'ga:pagePathLevel4', 'Page Path Level 4'
addDimension 'ga:pageTitle', 'Page Title'
addDimension 'ga:landingPagePath', 'Landing Page Path'
addDimension 'ga:secondPagePath', 'Second Page Path'
addDimension 'ga:exitPagePath', 'Exit Page Path'
addDimension 'ga:previousPagePath', 'Previous Page Path'
addDimension 'ga:nextPagePath', 'Next Page Path'
addDimension 'ga:pageDepth', 'Page Depth'

#Internal Search
addMetric 'ga:searchResultViews', 'Search Result Views'
addMetric 'ga:searchUniques', 'Unique Searches'
addMetric 'ga:avgSearchResultViews', 'Average Search Result Views'
addMetric 'ga:searchVisits', 'Search Visits'
addMetric 'ga:percentVisitsWithSearch', 'Percent Visits with Search'
addMetric 'ga:searchDepth', 'Search Depth'
addMetric 'ga:searchRefinements', 'Search Refinements'
addMetric 'ga:searchDuration', 'Search Duration'
addMetric 'ga:avgSearchDuration', 'Average Search Duration'
addMetric 'ga:searchExits', 'Search Exits'
addMetric 'ga:searchExitRate', 'Search Exit Rate'
addMetric 'ga:searchGoal(n)ConversionRate', 'Search Goal Conversion Rate', 'ga:searchGoal([0-9]+)ConversionRate'
addMetric 'ga:searchGoalConversionRateAll', 'Search All Goals Conversion Rate'
addMetric 'ga:goalValueAllPerSearch', 'Goal Value Per Search'

addDimension 'ga:searchUsed', 'Search Used'
addDimension 'ga:searchKeyword', 'Search Keyword'
addDimension 'ga:searchKeywordRefinement', 'Search Keyword Refinement'
addDimension 'ga:searchCategory', 'Search Category'
addDimension 'ga:searchStartPage', 'Search Start Page'
addDimension 'ga:searchDestinationPage', 'Search Destination Page'

#Site Speed
addMetric 'ga:pageLoadTime', 'Page Load Time'
addMetric 'ga:pageLoadSample', 'Page Load Sample'
addMetric 'ga:avgPageLoadTime', 'Average Page Load Time'
addMetric 'ga:domainLookupTime', 'Domain Lookup Time'
addMetric 'ga:avgDomainLookupTime', 'Average Domain Lookup Time'
addMetric 'ga:pageDownloadTime', 'Page Download Time'
addMetric 'ga:avgPageDownloadTime', 'Average Page Download Time'
addMetric 'ga:redirectionTime', 'Redirection Time'
addMetric 'ga:avgRedirectionTime', 'Average Redirection Time'
addMetric 'ga:serverConnectionTime', 'Server Connection Time'
addMetric 'ga:avgServerConnectionTime', 'Average Server Connection Time'
addMetric 'ga:serverResponseTime', 'Server Response Time'
addMetric 'ga:avgServerResponseTime', 'Average Server Response Time'
addMetric 'ga:speedMetricsSample', 'Speed Metrics Sample'
addMetric 'ga:domInteractiveTime', 'DOM Interactive Time'
addMetric 'ga:avgDomInteractiveTime', 'Average DOM Interactive Time'
addMetric 'ga:domContentLoadedTime', 'DOM Content Loaded Time'
addMetric 'ga:avgDomContentLoadedTime', 'Average DOM Content Loaded Time'
addMetric 'ga:domLatencyMetricsSample', 'DOM Latency Merics Sample'

#App Tracking
addMetric 'ga:appviews', 'App Views'
addMetric 'ga:uniqueAppviews', 'Unique App Views'
addMetric 'ga:appviewsPerVisit', 'App Views Per Visit'

#Event Tracking
addMetric 'ga:totalEvents', 'Total Events'
addMetric 'ga:uniqueEvents', 'Unique Events'
addMetric 'ga:eventValue', 'Event Value'
addMetric 'ga:avgEventValue', 'Average Event Value'
addMetric 'ga:visitsWithEvent', 'Visits With Event'
addMetric 'ga:eventsPerVisitWithEvent', 'Events Per Visit With Event'

addDimension 'ga:eventCategory', 'Event Category'
addDimension 'ga:eventAction', 'Event Action'
addDimension 'ga:eventLabel', 'Event Label'

#Ecommerce
addMetric 'ga:transactions', 'Transactions'
addMetric 'ga:transactionsPerVisit', 'Transactions Per Visit'
addMetric 'ga:transactionRevenue', 'Transaction Revenue'
addMetric 'ga:revenuePerTransaction', 'Revenue Per Transaction'
addMetric 'ga:transactionRevenuePerVisit', 'Transaction Revenue Per Visits'
addMetric 'ga:transactionShipping', 'Transaction Shipping'
addMetric 'ga:transactionTax', 'Transaction Tax'
addMetric 'ga:totalValue', 'Total Value'
addMetric 'ga:itemQuantity', 'Item Quantity'
addMetric 'ga:uniquePurchases', 'Unique Purchases'
addMetric 'ga:revenuePerItem', 'Revenue Per Item'
addMetric 'ga:itemRevenue', 'Item Revenue'
addMetric 'ga:itemsPerPurchase', 'Items Per Purchase'

addDimension 'ga:transactionId', 'Transaction Id'
addDimension 'ga:affiliation', 'Affiliation'
addDimension 'ga:visitsToTransaction', 'Visits To Transaction'
addDimension 'ga:daysToTransaction', 'Days To Transaction'
addDimension 'ga:productSku', 'Product Sku'
addDimension 'ga:productName', 'Product Name'
addDimension 'ga:productCategory', 'Product Category'

#Social Interactions
addMetric 'ga:socialInteractions', 'Social Interactions'
addMetric 'ga:uniqueSocialInteractions', 'Unique Social Interactions'
addMetric 'ga:socialInteractionsPerVisit', 'Social Interactions Per Visit'

addDimension 'ga:socialInteractionNetwork', 'Social Interaction Network'
addDimension 'ga:socialInteractionAction', 'Social Interaction Action'
addDimension 'ga:socialInteractionNetworkAction', 'Social Interaction Network Action'
addDimension 'ga:socialInteractionTarget', 'Social Interaction Target'

#User Timings
addMetric 'ga:userTimingValue', 'User Timing Value'
addMetric 'ga:userTimingSample', 'User Timing Sample'
addMetric 'ga:avgUserTimingValue', 'Average User Timing Value'

addDimension 'ga:userTimingCategory', 'User Timing Category'
addDimension 'ga:userTimingLabel', 'User Timing Label'
addDimension 'ga:userTimingVariable', 'User Timing Variable'

#Exception Tracking
addMetric 'ga:exceptions', 'Exceptions'
addMetric 'ga:fatalExceptions', 'Fatal Exceptions'

#Experiments
addDimension 'ga:experimentId', 'Experiment Id'
addDimension 'ga:experimentVariant', 'Experiment Variant'

#Custom Variables
addDimension 'ga:customVarName(n)', 'Custom Var Name', 'ga:customVarName([0-9]+)'
addDimension 'ga:customVarValue(n)', 'Custom Var Value', 'ga:customVarValue([0-9]+)'

#Time
addDimension 'ga:date', 'Date'
addDimension 'ga:year', 'Year'
addDimension 'ga:month', 'Month'
addDimension 'ga:week', 'Week'
addDimension 'ga:day', 'Day'
addDimension 'ga:hour', 'Hour'
addDimension 'ga:nthMonth', 'Nth Month'
addDimension 'ga:nthWeek', 'Nth Week'
addDimension 'ga:nthDay', 'Nth Day'
addDimension 'ga:dayOfWeek', 'Day Of Week'

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
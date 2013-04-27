gav
===

Google Analytics validator (GAV) for NodeJs. Easily validate Google Analytics query parameters.

##Usage##

Install gav through npm: `npm install gav`

```js
gav = require('gav');

//Do stuff...
```

##Methods##

###getDimension(dim)###

Gets a dimension by GA value.

**Arguments**

- `dim` - A string GA value of form _ga:value_

**Example**

```js
gav.getDimension('ga:browser'); //returns { value : 'ga:browser', name : 'Browser', regex : RegExpObject }
```

------------------------------------------------------------------

###getMetric(met)###

Gets a metric by GA value.

**Arguments**

- `met` - A string GA value of form _ga:value_

**Example**

```js
gav.getMetric('ga:visits'); //returns { value : 'ga:visits', name : 'Visits', regex : RegExpObject }
```

------------------------------------------------------------------

###checkDimension(dim)###

Checks whether a dimension is valid.

**Arguments**

- `dim` - A string GA value of form _ga:value_

**Example**

```js
gav.checkDimension('ga:browser'); //returns true
gav.checkDimension('ga:bad'); //returns false
```

------------------------------------------------------------------

###checkMetric(met)###

Checks whether a metric is valid.

**Arguments**

- `met` - A string GA value of form _ga:value_

**Example**

```js
gav.checkMetric('ga:visits'); //returns true
gav.checkMetric('ga:bad'); //returns false
```

------------------------------------------------------------------

###checkSort(sort)###

Checks whether a sort value is valid.

**Arguments**

- `sort` - A string GA sort value

**Example**

```js
gav.checkSort('-ga:visits'); //returns true
gav.checkSort('ga:visits'); //returns true
```

------------------------------------------------------------------

###checkSegment(seg)###

Checks whether a segment value is valid.

**Arguments**

- `seg` - A string GA segment value

**Example**

```js
gav.checkSegment('gaid:10'); //returns true
gav.checkSegment('dynamic::ga:medium==referral'); //returns true
```

------------------------------------------------------------------

###checkFilter(filter)###

Checks whether a filter value is valid.

**Arguments**

- `filter` - A string GA filter value

**Example**

```js
gav.checkSegment('ga:visits>10;ga:country==Canada'); //returns true
```

##License##

MIT

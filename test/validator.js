var validator = require('../');
var should = require('should');

describe('ga-validator', function(){
    describe('getMetric()', function(){
        it('should return metric objects for metric', function(){

            validator.metrics.forEach(function(metric){
                should.exist(validator.getMetric(metric.value.replace('(n)', '1')));
            });

        });

        it('should return null for invalid metric', function(){

            should.not.exist(validator.getMetric('ga:badMetric'));

        });

    });

    describe('getDimension', function(){
        it('should return dimension objects for dimension', function(){

            validator.dimensions.forEach(function(d){
                should.exist(validator.getDimension(d.value.replace('(n)', '1')));
            });

        });

        it('should return null for invalid dimension', function(){

            should.not.exist(validator.getDimension('ga:badDimension'));

        });
    });

    describe('checkMetric', function(){
        it('should verify a valid metric', function(){
            validator.metrics.forEach(function(metric){
               validator.checkMetric(metric.value.replace('(n)', '1')).should.be.true;
            });
        });

        it('should return false on invalid metric', function(){
            validator.checkMetric('ga:badMetric').should.be.false;
        });
    });

    describe('checkDimension', function(){
        it('should verify a valid dimension', function(){
            validator.dimensions.forEach(function(d){
                validator.checkDimension(d.value.replace('(n)', '1')).should.be.true;
            });
        });

        it('should return false on invalid dimension', function(){
            validator.checkDimension('ga:badDimension').should.be.false;
        });
    });

    describe('checkFilter', function(){
        it('should return true for valid filter', function(){
            validator.checkFilter('ga:visits>10;ga:country==Canada').should.be.true;
        });
    });

    describe('checkSort', function(){
        it('should verify valid sort', function(){

            validator.metrics.forEach(function(metric){
                validator.checkSort(metric.value.replace('(n)', '1')).should.be.true;
                validator.checkSort('-' + metric.value.replace('(n)', '1')).should.be.true;
            });

            validator.dimensions.forEach(function(d){
                validator.checkSort(d.value.replace('(n)', '1')).should.be.true;
                validator.checkSort('-' + d.value.replace('(n)', '1')).should.be.true;
            });
        });

        it('should return false on invalid sort', function(){
            validator.checkSort('-ga:badMetric').should.be.false;
            validator.checkSort('ga:badMetric').should.be.false;
        });
    });

    describe('checkSegment', function(){
        it('should return true for valid segments', function(){
            validator.checkSegment('gaid::10').should.be.true;
            validator.checkSegment('dynamic::ga:medium==referral').should.be.true;
        });
    });
});
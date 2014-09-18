"use strict"

angular.module('bookmarkApp', [])
    .controller('appCtrl', ['$scope', '$http',
        function($scope, $http) {
            $scope.test = "This is a test";

            $http({
                method: 'GET',
                url: 'http://zick.io:9009/nodes'
            }).
            success(function(data, status, headers, config) {
                // this callback will be called asynchronously
                // when the response is available
                $scope.bookmarkList = data;
                console.log(data);
            }).
            error(function(data, status, headers, config) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
                console.log("There is an error");
            });
        }
    ])
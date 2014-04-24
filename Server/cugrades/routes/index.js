exports.mockGetGrades = function(req, res){
    var mock = getMockGrades();

    mock.grades.push(newRandomGrade());

    res.send(JSON.stringify(mock));
};

exports.mockLogin = function(req, res){
    res.send(mockLoginResponse)
};

function getMockGrades(){
    return {"student": {
                "id":"100853179",
                "name":"Devin Lynch"
            },
            "term": {
                "id":"201410",
                "name":"Winter 2014 (January-April)",
                "startDate":null,"endDate":null
            },
            "grades":[
                
            ],
            "previousTermId":"201330",
            "nextTermId":null
        };
}

function newRandomGrade() {
    return {"courseId":"",
                "courseTitle":"COMP "+getRandom(1,10000),
                "courseDescription": "TEST COURSE " + getRandom(1,100000),
                "instructorName":null,
                "grade":"A+",
                "creditHours":"",
                "courseSection":"B",
                "instructorId":""
            };
}

function getRandom(min, max) {
    return min + Math.floor(Math.random() * (max - min + 1));
}

var mockLoginResponse = '?token=oIq8ciRMNjBDnxSI6vnPrFLaPao5pcO6mEjE5jSDNhGhVqKjyBo3WcPZPEfftnMC"tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt';
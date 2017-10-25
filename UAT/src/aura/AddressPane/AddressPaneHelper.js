({
	getShoreDate : function (component, ISODate){
        return (ISODate.getMonth()+1) +'/'+ (ISODate.getDate()) + '/' + (ISODate.getFullYear());
    },
    
    highlightFirstAddr: function(component, event, helper){
         $("div#mainDiv > div").children("article.selectedRow").removeClass("selectedRow");
         $("div#mainDiv > div:first > article").addClass("selectedRow");       
    }, 
    
})
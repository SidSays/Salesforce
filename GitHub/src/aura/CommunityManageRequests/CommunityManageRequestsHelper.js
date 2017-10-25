({
	sortBy: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            filteredCaseslst = component.get("v.filteredCaseslst");
        sortAsc = field != sortField || !sortAsc;
        filteredCaseslst.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.filteredCaseslst", filteredCaseslst);
    },
     applyFilter : function (component, collection, predicate){
        var result = [];        
        for(var j = 0; j < collection.length; j++){
            if(predicate(collection[j])){                
                result.push(collection[j]);
            }
        }            
        return result;            	
    },
})
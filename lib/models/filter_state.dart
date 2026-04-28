class FilterState {
  String type;        
  double minPrice;   
  double maxPrice;    
  bool availableOnly; 
  String sort;        

  FilterState({
    this.type = 'All',
    this.minPrice = 0,
    this.maxPrice = 300,
    this.availableOnly = false,
    this.sort = 'None',
  });

  FilterState copy() => FilterState(
        type: type,
        minPrice: minPrice,
        maxPrice: maxPrice,
        availableOnly: availableOnly,
        sort: sort,
      );

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (type != 'All') {
      params['type'] = type;
    }

    params['minPrice'] = minPrice.round().toString();
    params['maxPrice'] = maxPrice.round().toString();

    if (availableOnly) {
      params['available'] = '1';
    }

    if (sort != 'None') {
      params['sort'] = sort; 
    }

    return params;
  }
}
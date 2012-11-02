class LocationController < UITableViewController

  ReusablePinId = 'TaxiPin'
  ReusableCellId = 'TaxiCell'
  REGION_DELTA = 0.01

  def viewDidLoad
    super

    @results = @taxis ||= []

    self.title = 'Taxiii!'

    tableView.tableHeaderView = header
  end

  def viewWillAppear(animated)
    super
    gotoCurrentLocation
  end

  # UI

  def hideMap(hide)
    @mapView.setHidden(hide)
    # Shrink or expand table header
    head = self.tableView.tableHeaderView
    f = head.frame
    f.size.height += (hide ? -1 : +1) * @mapView.frame.size.height
    head.frame = f
    self.tableView.tableHeaderView = head
  end

  def centerAroundCoordinate(coordinate)
    if coordinate.is_a? CLLocationCoordinate2D
      region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(REGION_DELTA, REGION_DELTA))
      @mapView.setRegion @mapView.regionThatFits(region), animated:true
    end
  end

  def gotoCurrentLocation
    getLocation do |location, error_message|
      if location
        centerAroundCoordinate(location.coordinate)
        downloadTaxisAtCoordinate(location.coordinate)
      elsif error_message
        App.alert error_message
      else
        App.alert "Could not find your location"
      end
    end
  end

  # Location

  def getLocation(&block)
    BW::Location.get do |result|
      if result[:to]
        BW::Location.stop
        block.call result[:to], nil
      else
        block.call nil, "Could not find your location"
      end
    end
  end

  # UISearchBarDelegate protocol

  def searchBarShouldBeginEditing(searchBar)
    self.navigationController.setNavigationBarHidden(true, animated:true)
    hideMap(true)
    true
  end

  def searchBarShouldEndEditing(searchBar)
    self.navigationController.setNavigationBarHidden(false, animated:true)
    hideMap(false)
    true
  end

  def searchBar(searchBar, textDidChange:searchText)
    @results = @taxis.select { |v| v.name =~ /#{searchText}/i || v.address =~ /#{searchText}/i }
    self.tableView.reloadData
  end

  def searchBarSearchButtonClicked(searchBar)
    p "Search for #{searchBar.text}"
    searchBar.resignFirstResponder
  end

  def searchBarCancelButtonClicked(searchBar)
    searchBar.resignFirstResponder
  end

  # MKMapViewDelegate protocol

  def mapView(mapView, viewForAnnotation:annotation)
    pin = mapView.dequeueReusableAnnotationViewWithIdentifier(ReusablePinId) || begin
      MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:ReusablePinId)
    end
    pin
  end

  # UITableViewDataSource protocol

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(ReusableCellId) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:ReusableCellId)
    end
    taxi = @results[indexPath.row]
    cell.selectionStyle = UITableViewCellSelectionStyleGray
    cell.textLabel.text = taxi.name
    cell.textLabel.font = UIFont.boldSystemFontOfSize(13)
    cell.detailTextLabel.text = taxi.address
    cell.detailTextLabel.font = UIFont.systemFontOfSize(12)
    cell
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @results.size
  end

  # UITableViewDelegate protocol

  def header
    header_view = UIView.alloc.initWithFrame CGRectMake(0, 0, 320, 224)

    searchBar = UISearchBar.alloc.initWithFrame CGRectMake(0, 0, 320, 44)
    searchBar.delegate = self
    searchBar.placeholder = '¿Dónde te encuentras?'
    searchBar.tintColor = UIColor.lightGrayColor
    searchBar.showsCancelButton = true

    @mapView = MKMapView.alloc.initWithFrame CGRectMake(0, 44, 320, 180)
    @mapView.delegate = self
    @mapView.zoomEnabled = true

    header_view.addSubview searchBar
    header_view.addSubview @mapView
    header_view
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    60
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    # @taxis[indexPath.row]
  end

  # Networking

  def downloadTaxisAtCoordinate(coordinate)
  end

end


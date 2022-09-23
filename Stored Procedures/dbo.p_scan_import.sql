SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 * NAME:
 * p_scan_import
 * 
 * TYPE:
 * StoredProcedure
 * 
 * DESCRIPTION:
 * 	Inserts Scan data for Package tracking into the new shipment_log table
 * 
 * RETURN:
 * None.
 * 
 * RESULT SETS:
 * Refer to the final select statement for the return set. 
 *  See the comment "-- return the matching records".
 * The create table statement documentation lists the column id relative to the datawindow object.
 *  See the comment "-- create a temporary table in which to store the data for the return set". 
 *
 * PARAMETERS:
 * 01 @scan_order	int		Order Number of the Order for the scanned item
 * 02 @scan_station	varchar(12)	Scan station	
 * 03 @scan_citystate	varchar(30)	City/State of the scan location.
 * 
 * REFERENCES: (called by and calling references only, don't include table/view/object references)
 * 	Called by .Net com objects usually run as a service to import data from XML files.
 *
 * REVISION HISTORY:
 * Createed 12/01/05 PTS 30369 - DJM - Create Proc to import Tracking scans into the shipment_log table
 *
 **/

Create Proc [dbo].[p_scan_import] 
	@scan_order	varchar(12),
	@scan_station	varchar(30),
	@scan_citystate	varchar(30),
	@scan_empname	varchar(100),
	@scan_transtype	varchar(12),
	@scan_trailer	varchar(13),
	@scan_pieces	int,
	@scan_overage	int,
	@scan_shortage	int,
	@scan_damaged	int,
	@scan_datetime	datetime,
	@scan_filename	varchar(255)

as

Insert into shipment_log (sl_order, sl_station, sl_citystate, sl_empname, sl_transtype,
	sl_trailer, sl_pieces, sl_overage, sl_shortage, sl_damaged,
	sl_datetime, sl_filename)
Values(@scan_order,@scan_station, @scan_citystate, @scan_empname, @scan_transtype, @scan_trailer,
	@scan_pieces, @scan_overage, @scan_shortage, @scan_damaged, @scan_datetime,
	@scan_filename)

GO
GRANT EXECUTE ON  [dbo].[p_scan_import] TO [public]
GO

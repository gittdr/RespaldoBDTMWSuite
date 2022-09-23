SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[mov_number_by_ordref_sp]
	@p_refnum 	varchar(30)
AS	

/**
 * 
 * NAME:
 * mov_number_by_ordref_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns mov_numbers to be displayed in the Move Number Selection Window in the Trip Folder
 *
 * RETURNS: NONE
 *
 * RESULT SETS:  Set of mov_numbers to be displayed
 *
 * PARAMETERS:
 * @p_refnum	varchar(30)	Referencenumber that user has entered in the Trip Folder
 *
 * REVISION HISTORY:
 * 9/1/2005.01 ? PTS28041 - Dan Hudec ? Created Procedure
 * 68486 JJF 20130625 Adjusted existing select move number by order ref so that it takes multiple movements into account for order(s) found with associated reference number.
 **/
 
  
set nocount on
set transaction isolation level read uncommitted

DECLARE	@v_number_retrieved	int,
	@v_column_sorted	varchar(30),
	@v_asc_desc		varchar(4),
	@v_reftypes		VARCHAR(60),
	@v_sql			nvarchar(2000)

SELECT @v_number_retrieved = gi_string1, 
       @v_column_sorted = gi_string2, 
       @v_asc_desc = gi_string3,
       @v_reftypes = gi_string4
  FROM generalinfo
 WHERE gi_name = 'MaxTripsRetrieval'

IF ISNULL(@v_reftypes, '') <> ''
   SET @v_reftypes = ',' + LTRIM(RTRIM(@v_reftypes)) + ','

IF (@v_number_retrieved  > 0) and (IsNull(@v_column_sorted, '') <> '') and (IsNull(@v_asc_desc, '') <> '')
BEGIN
   IF ISNULL(@v_reftypes, '') <> ''
   BEGIN
      SET @v_sql = 'select distinct top ' + cast(@v_number_retrieved as nvarchar) + ' ' +
                   'ord_company, ord_number, ord_customer, ord_bookdate,
                    ord_bookedby, ord_status, ord_originpoint, ord_destpoint,
                    ord_supplier, ord_billto, ord_startdate, ord_completiondate,
                    ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4,
                    ord_totalweight, ord_totalpieces, ord_totalmiles, ord_totalcharge,
                    ord_totalvolume, o.ord_hdrnumber, r.ref_number, ord_remark,
                    ord_shipper, ord_consignee, s.mov_number, ord_driver1, ord_driver2,
                    ord_tractor, ord_trailer, ord_length, ord_width, ord_height,
                    r.ref_type, ord_description, cht_itemcode, ord_booked_revtype1' +
                   ' from stops s INNER JOIN orderheader o on o.ord_hdrnumber = s.ord_hdrnumber INNER JOIN referencenumber r ON r.ref_tablekey = o.ord_hdrnumber ' +
                   'where r.ref_table = ''orderheader'' and o.ord_status <>''CAN'' and ' +
                   'r.ref_number = ''' + @p_refnum + '''' + 
                   ' and CHARINDEX('','' + ref_type + '',''' + ',' + '''' + @v_reftypes + ''') > 0 ' +
                   'order by o.' + @v_column_sorted + ' ' + @v_asc_desc
      EXEC sp_executesql @v_sql
   END
   ELSE
   BEGIN
      SET @v_sql = 'select distinct top ' + cast(@v_number_retrieved as nvarchar) + ' ' 
		   + 'ord_company, ord_number, ord_customer, ord_bookdate,
		      ord_bookedby, ord_status, ord_originpoint, ord_destpoint,
		      ord_supplier, ord_billto, ord_startdate, ord_completiondate,
		      ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4,
		      ord_totalweight, ord_totalpieces, ord_totalmiles, ord_totalcharge,
		      ord_totalvolume, o.ord_hdrnumber, r.ref_number, ord_remark,
  		      ord_shipper, ord_consignee, s.mov_number, ord_driver1, ord_driver2,
		      ord_tractor, ord_trailer, ord_length, ord_width, ord_height,
		      r.ref_type, ord_description, cht_itemcode, ord_booked_revtype1 from stops s INNER JOIN orderheader AS o on o.ord_hdrnumber = s.ord_hdrnumber INNER JOIN referencenumber AS r ON r.ref_tablekey = o.ord_hdrnumber 
		      where r.ref_table = ''orderheader'' and o.ord_status <>''CAN'' and r.ref_number = ''' + @p_refnum + ''' order by o.' 
		   + @v_column_sorted + ' ' + @v_asc_desc
      EXEC sp_executesql @v_sql
   END
END 
ELSE
BEGIN
	select distinct	ord_company, ord_number, ord_customer, ord_bookdate,
		ord_bookedby, ord_status, ord_originpoint, ord_destpoint,
		ord_supplier, ord_billto, ord_startdate, ord_completiondate,
		ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4,
		ord_totalweight, ord_totalpieces, ord_totalmiles, ord_totalcharge,
		ord_totalvolume, o.ord_hdrnumber, ord_refnum, ord_remark,
		ord_shipper, ord_consignee, s.mov_number, ord_driver1, ord_driver2,
		ord_tractor, ord_trailer, ord_length, ord_width, ord_height,
		ord_reftype, ord_description, cht_itemcode, ord_booked_revtype1
	from 	stops s 
			INNER JOIN orderheader AS o on o.ord_hdrnumber = s.ord_hdrnumber 
			INNER JOIN referencenumber AS r ON 
		r.ref_tablekey = o.ord_hdrnumber
	where   r.ref_number = @p_refnum and
	      	r.ref_table = 'orderheader'
END

GO
GRANT EXECUTE ON  [dbo].[mov_number_by_ordref_sp] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[d_load_stops_compid_sp]  @ordnum int
AS
/*
PTS36363 JG Remove index hint on city.pk_code
 4/19/08 DPETE recode Pauls PH  11/20/06 - PTS35279 - jguo - remove index hints and double quotes.

*/

declare @ordnum1 int
  select @ordnum1 = isnull(@ordnum,0) 
  if @ordnum < 1 
      SELECT	'UNKNOWN' cmp_name,
		'UNKNOWN' cmp_id,
		'' cmp_address1,
		'' cmp_address2, 
		'' cty_nmstct,
		'' cmp_defaultbillto,
		'' cmp_defaultpriority,
		'' cmp_zip,
		'UNK' cmp_subcompany,
		'' cmp_currency,
		'UNKNOWN' cmp_shipper,
		'UNKNOWN' cmp_consingee,
		'UNKNOWN' cmp_billto,
		'' cmp_contact,
		'' cmp_misc1 ,
		0 stp_number,
		0 lgh_number,
		0 mov_number,
		'UNKNOWN' stp_event,
		'' cty_name,
		'' cty_state,
		'' cty_zip,
		'UNKNOWN' stp_type ,
      '' cmp_primaryphone,
      '' cmp_geoloc,
      0 cmp_city,
      '' cmp_altid
ELSE
   SELECT	c.cmp_name,
		c.cmp_id,
		c.cmp_address1,
		c.cmp_address2, 
		y.cty_nmstct,
		c.cmp_defaultbillto,
		c.cmp_defaultpriority,
		ISNULL (c.cmp_zip, '' )cmp_zip,
		c.cmp_subcompany,
		c.cmp_currency,
		c.cmp_shipper,
		c.cmp_consingee,
		c.cmp_billto,
		c.cmp_contact,
		SUBSTRING(c.cmp_misc1,1,30) cmp_misc1 ,
		s.stp_number,
		s.lgh_number,
		s.mov_number,
		s.stp_event,
		ISNULL(y.cty_name,'') cty_name,
		isnull(y.cty_state,'') cty_state,
		ISNULL(y.cty_zip,'') cty_zip,
		stp_type,
      cmp_primaryphone,
      cmp_geoloc,
      cmp_city,
      cmp_altid
   FROM		company c , --with(index=pk_id), 
    stops s , --with(index=sk_stp_ordnum), 
    city y 
   WHERE	c.cmp_id = s.cmp_id AND
		s.ord_hdrnumber = @ordnum1 AND @ordnum1<>0 and
		s.stp_city = y.cty_code and s.ord_hdrnumber <> 0
   ORDER BY	c.cmp_id , s.stp_number
GO
GRANT EXECUTE ON  [dbo].[d_load_stops_compid_sp] TO [public]
GO

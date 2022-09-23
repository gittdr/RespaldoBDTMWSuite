SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[get_purchase_transport_cost_sp]	@lgh_number	INTEGER
AS
DECLARE	@stp_number_start	INTEGER,
	@stp_number_end		INTEGER,
	@origin_zip 		VARCHAR(10),
	@dest_zip		VARCHAR(10),
	@origin_state		VARCHAR(6),
	@dest_state		VARCHAR(6),
	@trl_type1		VARCHAR(6),
        @arrivaldate		DATETIME,
	@ord_hdrnumber		INTEGER,
	@origin_region		INTEGER,
	@destination_region	INTEGER,
	@mode			VARCHAR(6),
	@ptc_rgh_type		INTEGER,
	@canadacount		SMALLINT

SELECT @ptc_rgh_type = ISNULL(code, 0)
  FROM labelfile
 WHERE labeldefinition = 'RegionTypes' AND
       name = 'PTC Regions'

IF @ptc_rgh_type = 0
BEGIN
   RETURN
END

SELECT @stp_number_start = stp_number
  FROM stops 
 WHERE stops.lgh_number = @lgh_number AND
       stops.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                                   FROM stops JOIN eventcodetable ect ON stops.stp_event = ect.abbr AND
                                                                        (ect.mile_typ_from_stop = 'LD' OR
                                                                         ect.mile_typ_to_stop = 'LD')
                                  WHERE stops.lgh_number = @lgh_number)

SELECT @stp_number_end = stp_number
  FROM stops
 WHERE stops.lgh_number = @lgh_number AND
       stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                   FROM stops JOIN eventcodetable ect ON stops.stp_event = ect.abbr AND
                                                                        (ect.mile_typ_from_stop = 'LD' OR
                                                                         ect.mile_typ_to_stop = 'LD')
                                  WHERE stops.lgh_number = @lgh_number)

SELECT TOP 1 @ord_hdrnumber = ord_hdrnumber
  FROM stops
 WHERE stops.lgh_number = @lgh_number AND
       stops.ord_hdrnumber > 0 

SELECT @origin_zip = stp_zipcode,
       @origin_state = stp_state,
       @arrivaldate = stp_arrivaldate
  FROM stops
 WHERE stops.stp_number = @stp_number_start

SELECT @dest_zip = stp_zipcode,
       @dest_state = stp_state
  FROM stops
 WHERE stops.stp_number = @stp_number_end

SELECT @trl_type1 = trl_type1
  FROM orderheader
 WHERE orderheader.ord_hdrnumber = @ord_hdrnumber

SELECT @canadacount = COUNT(*)
  FROM statecountry
 WHERE stc_country_c = 'CANADA' AND
       stc_state_c = @origin_state

IF @canadacount = 0
BEGIN
   SELECT @origin_region = regiondetail.rgh_number
     FROM regiondetail JOIN regionheader ON regiondetail.rgh_number = regionheader.rgh_number AND
                                            regionheader.rgh_type = @ptc_rgh_type
    WHERE regiondetail.rgd_type = 'ZIP' AND
          regiondetail.rgd_id = SUBSTRING(@origin_zip, 1, 3)
END

IF @canadacount > 0
BEGIN
   SELECT @origin_region = regiondetail.rgh_number
     FROM regiondetail JOIN regionheader ON regiondetail.rgh_number = regionheader.rgh_number AND
                                            regionheader.rgh_type = @ptc_rgh_type
    WHERE regiondetail.rgd_type = 'STATE' AND
          regiondetail.rgd_id = @origin_state
END

SELECT @canadacount = COUNT(*)
  FROM statecountry
 WHERE stc_country_c = 'CANADA' AND
       stc_state_c = @dest_state
  
IF @canadacount = 0
BEGIN
   SELECT @destination_region = regiondetail.rgh_number
     FROM regiondetail JOIN regionheader ON regiondetail.rgh_number = regionheader.rgh_number AND
                                            regionheader.rgh_type = @ptc_rgh_type
    WHERE regiondetail.rgd_type = 'ZIP' AND
          regiondetail.rgd_id = SUBSTRING(@dest_zip, 1, 3)
END

IF @canadacount > 0
BEGIN
   SELECT @destination_region = regiondetail.rgh_number
     FROM regiondetail JOIN regionheader ON regiondetail.rgh_number = regionheader.rgh_number AND
                                            regionheader.rgh_type = @ptc_rgh_type
    WHERE regiondetail.rgd_type = 'STATE' AND
          regiondetail.rgd_id = @dest_state
END

SELECT @mode = ISNULL(SUBSTRING(label_extrastring1, 1, 6), 'UNK')
  FROM labelfile
 WHERE labeldefinition = 'TrlType1' AND
       abbr = @trl_type1

SELECT TOP 1 ptc_id, 
       ptc_origin, 
       ptc_destination,
       ptc_linehaul,
       ptc_linehaul_permile,
       ptc_fsc_table, 
       ptc_date, 
       ptc_amtover,
       ptc_amtover_basis, 
       ptc_level, 
       ptc_locked,
       ptc_minmargin, 
       ptc_minmargin_basis, 
       ptc_minmargin_locked,
       ptc_mode,
       ptc_updateddate,
       ptc_updatedby
  FROM purchase_transport_cost
 WHERE ptc_origin = @origin_region AND
       ptc_destination = @destination_region AND
       ptc_mode = @mode AND
       ptc_date <= @arrivaldate
ORDER BY ptc_date desc
       
GO
GRANT EXECUTE ON  [dbo].[get_purchase_transport_cost_sp] TO [public]
GO

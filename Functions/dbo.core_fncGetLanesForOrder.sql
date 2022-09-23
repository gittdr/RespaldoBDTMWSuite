SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[core_fncGetLanesForOrder] (
@ord_hdrnumber int
)
returns @Lanes table
	(LaneId		int,
	LaneName	varchar(50),
	Specificity	int,
	Radius int)
as
begin
	
DECLARE @OriginCountryCode	VARCHAR(6),
	@OriginStateAbbr 	VARCHAR(6),
	@OriginCounty 		VARCHAR(50),
	@OriginCityCode 	INT,
	@OriginZip 		VARCHAR(10),
	@OriginCompanyId 	VARCHAR(8),
	@DestCountryCode 	VARCHAR(6),
	@DestStateAbbr 		VARCHAR(6),
	@DestCounty 		VARCHAR(50),
	@DestCityCode 		INT,
	@DestZip 		VARCHAR(10),
	@DestCompanyId 		VARCHAR(8),
	@stp_number_start	INT,
	@stp_number_end		INT,
	@lgh_externalrating_miles INT

   SELECT @stp_number_start = stp_number
     FROM stops
    WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
          stops.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                                      FROM stops
                                     WHERE stops.ord_hdrnumber = @ord_hdrnumber)

   SELECT @stp_number_end = stp_number
     FROM stops
    WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
          stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                      FROM stops
                                     WHERE stops.ord_hdrnumber = @ord_hdrnumber)
   
   IF @stp_number_start > 0 AND @stp_number_end > 0
   BEGIN
      SELECT @origincompanyid = cmp_id,
             @origincitycode = stp_city,
             @originstateabbr = stp_state,
             @originzip = stp_zipcode
        FROM stops
       WHERE stp_number = @stp_number_start
      IF @origincitycode > 0
         SELECT @origincounty = cty_county
           FROM city
          WHERE cty_code = @origincitycode
      IF @originstateabbr IS NOT NULL AND @originstateabbr <> '' AND LEN(@originstateabbr) > 0
         SELECT @origincountrycode = left(stc_country_c,3)
           FROM statecountry
          WHERE stc_state_c = @originstateabbr

      SELECT @destcompanyid = cmp_id,
             @destcitycode = stp_city,
             @deststateabbr = stp_state,
             @destzip = stp_zipcode
        FROM stops
       WHERE stp_number = @stp_number_end
      IF @destcitycode > 0
         SELECT @destcounty = cty_county
           FROM city
          WHERE cty_code = @destcitycode
      IF @deststateabbr IS NOT NULL AND @deststateabbr <> '' AND LEN(@deststateabbr) > 0
         SELECT @destcountrycode = left(stc_country_c,3)
           FROM statecountry
          WHERE stc_state_c = @deststateabbr

	SELECT top 1 @lgh_externalrating_miles = lgh_externalrating_miles
	FROM legheader (nolock)
	WHERE ord_hdrnumber = @ord_hdrnumber 
	
insert @Lanes SELECT ln.LaneId,
                MAX(ln.LaneName) as LaneName,
                MAX(oloc.SpecificityCode) | MAX(dloc.SpecificityCode) as Specificity,
				MAX(dloc.Radius) as Radius
           FROM core_Lane AS ln INNER JOIN core_LaneLocation AS oloc ON (oloc.IsOrigin = 1 and ln.LaneId = oloc.LaneId)
                                INNER JOIN core_LaneLocation AS dloc ON (dloc.IsOrigin = 2 and ln.LaneId = dloc.LaneId)
          WHERE (oloc.CountryCode IS NULL OR left(oloc.CountryCode,3) = @OriginCountryCode) AND
                (oloc.StateAbbr IS NULL OR oloc.StateAbbr = @OriginStateAbbr) AND
                (oloc.County IS NULL OR oloc.County = @OriginCounty) AND
                (oloc.CityCode IS NULL OR oloc.CityCode = @OriginCityCode) AND
                (oloc.ZipPart IS NULL OR @OriginZip like (oloc.ZipPart + '%')) AND
                (oloc.CompanyId IS NULL OR oloc.CompanyId = @OriginCompanyId) AND
                (dloc.CountryCode IS NULL OR left(dloc.CountryCode,3) = @DestCountryCode) AND
                (dloc.StateAbbr IS NULL OR dloc.StateAbbr = @DestStateAbbr) AND
                (dloc.County IS NULL OR dloc.County = @DestCounty) AND
                (dloc.CityCode IS NULL OR dloc.CityCode = @DestCityCode) AND
                (dloc.ZipPart IS NULL OR @DestZip like (dloc.ZipPart + '%')) AND
                (dloc.CompanyId IS NULL OR dloc.CompanyId = @DestCompanyId) AND
				(IsNull(dloc.Radius,0) = 0 OR dloc.Radius > @lgh_externalrating_miles)
		  GROUP BY ln.LaneId
         order by specificity desc
   END
   Return
End


GO
GRANT REFERENCES ON  [dbo].[core_fncGetLanesForOrder] TO [public]
GO
GRANT SELECT ON  [dbo].[core_fncGetLanesForOrder] TO [public]
GO

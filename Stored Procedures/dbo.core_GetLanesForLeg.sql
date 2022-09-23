SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- core_GetLanesForLeg has been deprecated in favor of core_fncGetLanesForLeg 
create proc [dbo].[core_GetLanesForLeg] (
@lgh_number int
) as
-- core_GetLanesForLeg has been deprecated in favor of core_fncGetLanesForLeg 	
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

   SELECT @stp_number_start = stp_number_start,
          @stp_number_end = stp_number_end
     FROM legheader (nolock)
    WHERE lgh_number = @lgh_number

   IF @stp_number_start > 0 AND @stp_number_end > 0
   BEGIN
      SELECT @origincompanyid = cmp_id,
             @origincitycode = stp_city,
             @originstateabbr = stp_state,
             @originzip = stp_zipcode
        FROM stops (nolock)
       WHERE stp_number = @stp_number_start
      IF @origincitycode > 0
         SELECT @origincounty = cty_county
           FROM city (nolock)
          WHERE cty_code = @origincitycode
      IF @originstateabbr IS NOT NULL AND @originstateabbr <> '' AND LEN(@originstateabbr) > 0
         SELECT @origincountrycode = left(stc_country_c,3)
           FROM statecountry (nolock)
          WHERE stc_state_c = @originstateabbr

      SELECT @destcompanyid = cmp_id,
             @destcitycode = stp_city,
             @deststateabbr = stp_state,
             @destzip = stp_zipcode
        FROM stops (nolock)
       WHERE stp_number = @stp_number_end
      IF @destcitycode > 0
         SELECT @destcounty = cty_county
           FROM city (nolock)
          WHERE cty_code = @destcitycode
      IF @deststateabbr IS NOT NULL AND @deststateabbr <> '' AND LEN(@deststateabbr) > 0
         SELECT @destcountrycode = left(stc_country_c,3)
           FROM statecountry (nolock)
          WHERE stc_state_c = @deststateabbr

	SELECT @lgh_externalrating_miles = lgh_externalrating_miles
	FROM legheader (nolock)
	WHERE lgh_number = @lgh_number

         SELECT ln.LaneId,
                MAX(ln.LaneName) as LaneName,
                MAX(oloc.SpecificityCode) | MAX(dloc.SpecificityCode) as Specificity,
				MAX(IsNull(dloc.Radius,0)) as Radius
           FROM core_Lane AS ln (nolock) 
								INNER JOIN core_LaneLocation AS oloc (nolock) ON (oloc.IsOrigin = 1 and ln.LaneId = oloc.LaneId)
                                INNER JOIN core_LaneLocation AS dloc (nolock) ON (dloc.IsOrigin = 2 and ln.LaneId = dloc.LaneId)
		 GROUP BY ln.LaneId
          HAVING (max(IsNull(oloc.CountryCode,'')) = '' OR left(max(IsNull(oloc.CountryCode,'')),3) = @OriginCountryCode) AND
                (max(IsNull(oloc.StateAbbr,'')) = '' OR max(IsNull(oloc.StateAbbr,'')) = @OriginStateAbbr) AND
                (max(IsNull(oloc.County,'')) = '' OR max(IsNull(oloc.County,'')) = @OriginCounty) AND
                (max(IsNull(oloc.CityCode,'')) = '' OR max(IsNull(oloc.CityCode,'')) = @OriginCityCode) AND
                (max(IsNull(oloc.ZipPart,'')) = '' OR @OriginZip like (max(IsNull(oloc.ZipPart,'')) + '%')) AND
                (max(IsNull(oloc.CompanyId,'')) = '' OR max(IsNull(oloc.CompanyId,'')) = @OriginCompanyId) AND
                (max(IsNull(dloc.CountryCode,'')) = '' OR left(max(IsNull(dloc.CountryCode,'')),3) = @DestCountryCode) AND
                (max(IsNull(dloc.StateAbbr,'')) = '' OR max(IsNull(dloc.StateAbbr,'')) = @DestStateAbbr) AND
                (max(IsNull(dloc.County,'')) = '' OR max(IsNull(dloc.County,'')) = @DestCounty) AND
                (max(IsNull(dloc.CityCode,'')) = '' OR max(IsNull(dloc.CityCode,'')) = @DestCityCode) AND
                (max(IsNull(dloc.ZipPart,'')) = '' OR @DestZip like (max(IsNull(dloc.ZipPart,'')) + '%')) AND
                (max(IsNull(dloc.CompanyId,'')) = '' OR max(IsNull(dloc.CompanyId,'')) = @DestCompanyId) AND
				(max(IsNull(dloc.Radius,0)) = 0 OR max(IsNull(dloc.Radius,0)) > @lgh_externalrating_miles)
	order by specificity desc
end

GO
GRANT EXECUTE ON  [dbo].[core_GetLanesForLeg] TO [public]
GO

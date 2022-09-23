SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[tmail_update_cmp_latlong2] ( @cmpid varchar(25), /*--PTS 61189 CMP_ID INCREASE LENGTH TO 25*/
 @stpnumber int, @pnewlat varchar(20), @pnewlong varchar(20), @flags varchar(12))
as

/***
   In:
       @cmpid:		If not available, supply @stpnumber.
       @stpnumber:	Only used if cmpid = ''
       @pnewlat:	Latitude in degrees.
       @pnewlong:	Longitude in degrees, with reverse sign.
  						Sign reversed, because that is how it is stored in TotalMail tblMessages.
                        Parm is typically filled from business rule LAT, which takes the value
  							of tblMessages.Longitude.
  	   @flags:		1 = only update if stp_aad_arv_confidence >= 1; only applies if @stpnumber <> 0 and @cmp_id = ''
***/

SET NOCOUNT ON 

declare @newlatseconds int, 
	@newlongseconds int,
	@tolerance int,
	@toleranceResponse varchar(20),
	@ActualDistance float,
	@newlat float,
	@newlong float,
	@curLat float,
	@curLong float,
	@curConfidence int,
	@newLatText varchar(20),
	@newLongText varchar(20),
	@curLatText varchar(20),
	@curLongText varchar(20),
	@ActDistText varchar(20),
	@stp_aad_arvConfidence int,
	@intFlags int,
	@request_code int

if isnumeric(@pnewlat)= 0 or isnumeric(@pnewlong) = 0
	RETURN

select 
	@tolerance = isnull(min(isnull(gi_integer1, -1)), -1), 
	@toleranceResponse = isnull(min(isnull(gi_string1, 'I')), 'I') 
	from generalinfo where gi_name = 'TMUpdCmpLatLongTolerance'

select @cmpid= isnull(@cmpid,''),
	@stpnumber = isnull(@stpnumber, 0)
	
if isnumeric(@flags) = 0
	select @flags = '0'
select @intFlags = convert(int, @flags)
	
if (@cmpid = '' or @cmpid = 'UNKNOWN') and @stpnumber > 0
	select @cmpid = cmp_id, @stp_aad_arvConfidence = stp_aad_arvConfidence 
		from stops where stp_number = @stpnumber
select @cmpid= isnull(@cmpid,''),
	@stp_aad_arvConfidence = isnull(@stp_aad_arvConfidence,0)

select @newlat = convert(float, @pnewlat), 
	@newlong = convert(float, @pnewlong) 

select  @newlatseconds = convert(int, @newlat * 3600),
	@newlongseconds = convert(int, @newlong * 3600) 
		-- Keep reversed sign, because longitude is stored with reverse sign on TMWS company.

if @newlatseconds = 0 and @newlongseconds = 0
	RETURN

if (LEFT(@cmpid,4) <> 'STP:') AND (LEFT(@cmpid,4) <> 'CTY:')
BEGIN	
	if (select count(*) from company where cmp_id = @cmpid and @cmpid<>'UNKNOWN')=0
		BEGIN
		RAISERROR ('Attempt to update latlong for unknown company id: %s; stop number: %d', 16, 1, @cmpid, @stpnumber)
		RETURN
		END

	if (select isnull(cmp_latlongverifications, 0) from company where cmp_id = @cmpid) < 0
		RETURN
END

if @intFlags & 1 > 0 -- Update only if high confidence gps reading
	if @stp_aad_arvConfidence < 1 
		RETURN

if @tolerance <> -1
	BEGIN
	SELECT @curLat = isnull(cmp_latseconds, 0)/3600., 
		@curLong = isnull(cmp_longseconds, 0)/3600., 
		@curConfidence = isnull(cmp_latlongverifications, 0)
		from company where cmp_id = @cmpid

	if @curConfidence <> 0
		BEGIN
		exec dbo.tmail_airdistance @curLat, @curLong, @newlat, @newlong, @ActualDistance out
		if isnull(@ActualDistance, 0) > @tolerance
			BEGIN
			IF @toleranceResponse = 'E'
				BEGIN
				SELECT 	@newLatText = convert(varchar(20), @newlat),
					@newLongText = convert(varchar(20), @newlong),
					@curLatText = convert(varchar(20), @curlat),
					@curLongText = convert(varchar(20), @curlong),
					@ActDistText = convert(varchar(20), @ActualDistance)
				
				RAISERROR ('Update %s LatLong failed: New position (%s, %s) is %s miles from Current position (%s, %s)', 16,1, @cmpid, @newlattext, @newlongtext, @ActDistText, @curLatText, @curLongText)
				END
			RETURN
			END
		END
	END

if (LEFT(@cmpid,4) = 'STP:')
	BEGIN
		set @request_code = CONVERT(int, SUBSTRING(@cmpid,5,len(@cmpid)-4))
		UPDATE stops SET stp_GeoCodeRequested = GetDate() WHERE stp_number = @request_code
	END
ELSE IF (LEFT(@cmpid,4) = 'CTY:')
	BEGIN
		set @request_code = CONVERT(int, SUBSTRING(@cmpid,5,len(@cmpid)-4))
		UPDATE city SET cty_GeoCodeRequested = GetDate() WHERE cty_code = @request_code
	END
ELSE
	BEGIN
	update company set cmp_latlongverifications = isnull(cmp_latlongverifications, 0) + 1
		where cmp_id = @cmpid
	update company set
		cmp_latseconds = isnull(cmp_latseconds, 0) + ((@newlatseconds - isnull(cmp_latseconds, 0)) /  cmp_latlongverifications),
		cmp_longseconds = isnull(cmp_longseconds, 0) + ((@newlongseconds - isnull(cmp_longseconds, 0)) /  cmp_latlongverifications),
		cmp_GeoCodeRequested = GetDate() 
		where cmp_id = @cmpid
	END

GO
GRANT EXECUTE ON  [dbo].[tmail_update_cmp_latlong2] TO [public]
GO

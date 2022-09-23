SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROCEDURE [dbo].[core_lane_create_from_route_sp] (@origin_type int,
											@origin_value varchar(50),
											@dest_type int,
											@dest_value varchar(50),
											@updatedby varchar(20),
											@carrierhub varchar(1),
											@new_laneid	int	OUTPUT,
											@new_lanecode varchar(15) OUTPUT
				)

AS

DECLARE @destabbr		varchar(3)
DECLARE @originabbr		varchar(3)
DECLARE @lanecode		varchar(15)
DECLARE @lanename varchar(50)

DECLARE @origin_companyid	varchar(8)
DECLARE @origin_cityname	varchar(50)
DECLARE @origin_zippart		varchar(10)
DECLARE @origin_county		varchar(50)
DECLARE @origin_stateabbr	varchar(6)
DECLARE @origin_countrycode	varchar(6)

DECLARE @dest_companyid	varchar(8)
DECLARE @dest_cityname	varchar(50)
DECLARE @dest_zippart		varchar(10)
DECLARE @dest_county		varchar(50)
DECLARE @dest_stateabbr	varchar(6)
DECLARE @dest_countrycode	varchar(6)

DECLARE @giveup smallint
DECLARE @lanecode_exists smallint
DECLARE @increment int
DECLARE @lanecode_touse varchar(15)

IF @origin_type = 1 BEGIN
	SELECT @originabbr = 'CMP', @origin_companyid = @origin_value
END
ELSE IF @origin_type = 2 BEGIN
	SELECT @originabbr = 'CTY', @origin_cityname = @origin_value
END	
ELSE IF @origin_type = 3 BEGIN
	SELECT @originabbr = 'ZIP', @origin_zippart = @origin_value
END	
ELSE IF @origin_type = 4 BEGIN
	SELECT @originabbr = 'CT', @origin_county = @origin_value
END	
ELSE IF @origin_type = 5 BEGIN
	SELECT @originabbr = 'ST', @origin_stateabbr = @origin_value
END	
ELSE IF @origin_type = 6 BEGIN
	SELECT @originabbr = 'CN', @origin_countrycode = @origin_value
END	

IF @dest_type = 1 BEGIN
	SELECT @destabbr = 'CMP', @dest_companyid = @dest_value
END
ELSE IF @dest_type = 2 BEGIN
	SELECT @destabbr = 'CTY', @dest_cityname = @dest_value
END	
ELSE IF @dest_type = 3 BEGIN
	SELECT @destabbr = 'ZIP', @dest_zippart = @dest_value
END	
ELSE IF @dest_type = 4 BEGIN
	SELECT @destabbr = 'CT', @dest_county = @dest_value
END	
ELSE IF @dest_type = 5 BEGIN
	SELECT @destabbr = 'ST', @dest_stateabbr = @dest_value
END	
ELSE IF @dest_type = 6 BEGIN
	SELECT @destabbr = 'CN', @dest_countrycode = @dest_value
END	


SET @lanecode =  left(@origin_value, 7) + '-' + left(@dest_value, 7)
SET @lanename = @origin_value + ' TO ' + @dest_value

--If lanecode exists, modify it
SET @lanecode_exists = 1
SET @increment = 0
SET @lanecode_touse = @lanecode
SET @giveup = 0

WHILE (@lanecode_exists > 0 AND @giveup = 0) BEGIN
	SELECT @lanecode_exists = count(*) 
	FROM core_lane 
	WHERE lanecode = @lanecode_touse

	IF @lanecode_exists > 0 BEGIN
		SET @increment = @increment + 1
		SET @lanecode_touse = RIGHT(@lanecode + '-' + cast(@increment as varchar(6)), 15)
		IF @increment > 99 BEGIN
			SET @giveup = 1
		END
	END
END

IF @giveup = 0 BEGIN
	INSERT core_lane(lanecode, lanename, updatedby, yn_carrierhub)
	SELECT @lanecode_touse, @lanename, @updatedby, @carrierhub


	SELECT @new_laneid = SCOPE_IDENTITY()
	SELECT @new_lanecode = @lanecode_touse

	INSERT INTO core_lanelocation
						  (laneid, IsOrigin, type, countrycode, stateabbr, county, cityname, zippart, companyid)
	VALUES     (@new_laneid, 1, @origin_type, @origin_countrycode, @origin_stateabbr, @origin_county, @origin_cityname, @origin_zippart, @origin_companyid)


	INSERT INTO core_lanelocation
						  (laneid, IsOrigin, type, countrycode, stateabbr, county, cityname, zippart, companyid)
	VALUES     (@new_laneid, 2, @dest_type, @dest_countrycode, @dest_stateabbr, @dest_county, @dest_cityname, @dest_zippart, @dest_companyid)
END
GO
GRANT EXECUTE ON  [dbo].[core_lane_create_from_route_sp] TO [public]
GO

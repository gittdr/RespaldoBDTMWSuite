SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetLoadRequirement] (@OrdHdrNumber VARCHAR(12), 
                                               @CompanyID VARCHAR(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
                                               @MoveNumber VARCHAR(12), 
                                               @LegNumber VARCHAR(12), 
                                               @StopNumber VARCHAR(12), 
                                               @EquipType VARCHAR(6))
AS

SET NOCOUNT ON 

	DECLARE @SQLWhere varchar(MAX)
	DECLARE @SQLBase varchar(MAX)
	DECLARE @StopType varchar(6)
	DECLARE @sComm varchar(4000)
	DECLARE @fgt_cmd_code varchar(8)
	DECLARE @fgt_SN int
	DECLARE @OrdHdrAcceptable varchar(100)
	DECLARE @CompanyAcceptable varchar(100)
	DECLARE @MovNumAcceptable varchar(100)
	DECLARE @LghNumAcceptable varchar(100)
	DECLARE @StpNumAcceptable varchar(100)
	DECLARE @StpTypeAcceptable varchar(100)
	DECLARE @EqpTypeAcceptable varchar(100)
	
	SELECT @SQLWhere = ''
	SELECT @SQLBase =
		'SELECT lrq_equip_type AS EquipType, lrq_type AS ReqType, 
			ReqTypeDescription = CASE 	
                          WHEN t1.lrq_equip_type = ''TRL'' THEN (SELECT name FROM labelfile WHERE labeldefinition = ''TrlAcc'' AND abbr = t1.lrq_type)
                          WHEN t1.lrq_equip_type = ''DRV'' THEN (SELECT name FROM labelfile WHERE labeldefinition = ''DrvAcc'' AND abbr = t1.lrq_type)
                          WHEN t1.lrq_equip_type = ''TRC'' THEN (SELECT name FROM labelfile WHERE labeldefinition = ''TrcAcc'' AND abbr = t1.lrq_type)
                        END,
			lrq_manditory AS ReqMandatory, 
			lrq_quantity AS ReqQuantity,
			def_id_type AS ReqDefIdType,
			cmd_code AS CommodityCode,
			CommodityName = (SELECT cmd_name FROM commodity WHERE cmd_code = t1.cmd_code),
			ord_hdrnumber AS OrdHdrNumber,
			mov_number AS MoveNumber,
			lgh_number AS LegNumber,
			stp_number AS StopNumber,
			lrq_not as ReqNot,
			CASE t1.lrq_manditory 
                          WHEN ''Y'' THEN ''must'' 
                          ELSE ''should'' 
                        END MandatoryText,
			CASE t1.lrq_not 
                          WHEN ''Y'' THEN ''have/be''
                          ELSE ''not have/be'' 
                        END NotText,
                        (SELECT ISNULL(min(ISNULL(name, '''')), '''') FROM labelfile WHERE abbr = t1.lrq_type and labeldefinition like ''%acc'') RequirementText
		FROM LoadRequirement t1 
		WHERE 1=2 '

	-- Clean up parameters.  If parm has any invalid value, reset it to an empty string.
	IF (ISNUMERIC(@OrdHdrNumber) = 0 OR @OrdHdrNumber = '0') SELECT @OrdHdrNumber = ''
	IF (ISNUMERIC(@MoveNumber) = 0 OR @MoveNumber = '0') SELECT @MoveNumber = ''
	IF (ISNUMERIC(@LegNumber) = 0 OR @LegNumber = '0') SELECT @LegNumber = ''
	IF (ISNUMERIC(@StopNumber) = 0 OR @StopNumber = '0') SELECT @StopNumber = ''
	IF (@CompanyID = 'UNKNOWN' OR @CompanyID IS NULL) SELECT @CompanyID = ''
	IF (@EquipType IS NULL) SELECT @EquipType = ''

	-- Make sure we have at least a minimal set of parameters.
	IF (@OrdHdrNumber = '') AND (@CompanyID = '') AND (@MoveNumber = '') AND (@LegNumber = '') AND (@StopNumber = '')
	BEGIN
		EXEC(@SQLBase)
		RETURN
	END

	-- Use parameters we are given to try to infer missing ones.
	IF (@StopNumber = '' AND @CompanyID <> '' AND @MoveNumber > '0' AND (SELECT COUNT(*) FROM stops WHERE mov_number = @MoveNumber AND cmp_id = @CompanyID) = 1)
		SELECT @StopNumber = stp_number FROM stops WHERE mov_number = @MoveNumber AND cmp_id = @CompanyID

	IF (@StopNumber = '' AND @CompanyID <> '' AND @LegNumber > '0' AND (SELECT COUNT(*) FROM stops WHERE lgh_number = @LegNumber AND cmp_id = @CompanyID) = 1)
		SELECT @StopNumber = stp_number FROM stops WHERE lgh_number = @LegNumber AND cmp_id = @CompanyID

	IF (@StopNumber = '' AND @CompanyID <> '' AND @OrdHdrNumber > '0' AND (SELECT COUNT(*) FROM stops WHERE ord_hdrnumber = @OrdHdrNumber AND cmp_id = @CompanyID) = 1)
		SELECT @StopNumber = stp_number FROM stops WHERE ord_hdrnumber = @OrdHdrNumber AND cmp_id = @CompanyID

	IF (@StopNumber > '0' AND @CompanyID = '')
		SELECT @CompanyID = cmp_id FROM stops WHERE stp_number = CONVERT(int, @StopNumber)
	IF (@CompanyID = 'UNKNOWN' OR @CompanyID IS NULL) SELECT @CompanyID = ''

	IF (@StopNumber > '0' AND @OrdHdrNumber = '')
		SELECT @OrdHdrNumber = ord_hdrnumber FROM stops WHERE stp_number = CONVERT(int, @StopNumber)
	IF (ISNUMERIC(@OrdHdrNumber) = 0 OR @OrdHdrNumber = '0') SELECT @OrdHdrNumber = ''		

	IF (@StopNumber > '0' AND @LegNumber = '')
		SELECT @LegNumber = lgh_number FROM stops WHERE stp_number = CONVERT(int, @StopNumber)
	IF (ISNUMERIC(@LegNumber) = 0 OR @LegNumber = '0') SELECT @LegNumber = ''

	IF (@LegNumber > '0' AND @MoveNumber = '')
		SELECT @MoveNumber = mov_number FROM legheader WHERE lgh_number = CONVERT(int, @LegNumber)
	IF (ISNUMERIC(@MoveNumber) = 0 OR @MoveNumber = '0') SELECT @MoveNumber = ''

	-- If Stop was determined, get stop type so can filter out requirements for wrong type of stop
	IF (@StopNumber > '0')
		SELECT @StopType = stp_type FROM Stops (NOLOCK) WHERE stp_number = @StopNumber
	IF (@StopType IS NULL) SELECT @StopType = ''

	-- Now generate a commodity list, either from the commodities at a stop (if stop is known), or from commodities on order (if order is known)
	SET @sComm = ''
	IF (@StopNumber > '0')
		BEGIN
		SELECT @fgt_cmd_code= MIN(cmd_code) 
		FROM freightdetail (NOLOCK)
		WHERE stp_number = @StopNumber AND cmd_code > ''
		WHILE ISNULL(@fgt_cmd_code, '') > ''
			BEGIN
			IF (@fgt_cmd_code <> 'UNKNOWN')
				SET @sComm = @sComm + ',' + QUOTENAME(@fgt_cmd_code, '''')
			SELECT @fgt_cmd_code= MIN(cmd_code) 
			FROM freightdetail (NOLOCK)
			WHERE stp_number = @StopNumber AND cmd_code > @fgt_cmd_code
			END
		END
	ELSE IF (@OrdHdrNumber > '0')
		BEGIN
		SELECT @fgt_cmd_code= MIN(freightdetail.cmd_code) 
		FROM freightdetail (NOLOCK) INNER JOIN stops ON freightdetail.stp_number = stops.stp_number
		WHERE stops.ord_hdrnumber = @OrdHdrNumber AND freightdetail.cmd_code > ''
		WHILE ISNULL(@fgt_cmd_code, '') > ''
			BEGIN
			IF (@fgt_cmd_code <> 'UNKNOWN')
				SET @sComm = @sComm + ',' + QUOTENAME(@fgt_cmd_code, '''') 
			SELECT @fgt_cmd_code= MIN(freightdetail.cmd_code) 
			FROM freightdetail (NOLOCK) INNER JOIN stops ON freightdetail.stp_number = stops.stp_number
			WHERE stops.ord_hdrnumber = @OrdHdrNumber AND freightdetail.cmd_code > @fgt_cmd_code
			END
		END
	IF @sComm <> '' SELECT @sComm = SUBSTRING(@sComm, 2, 3999) -- If commodity list was generated, strip off spurious initial comma.
	
	-- Now make filter items for each criteria.	
	IF (@OrdHdrNumber = '') 
		SELECT @OrdHdrAcceptable = ''
	ELSE
		SELECT @OrdHdrAcceptable = ' AND (ord_hdrnumber = ' + @OrdHdrNumber + ' OR ord_hdrnumber = 0 OR ord_hdrnumber IS NULL)'
		
	IF (@CompanyID = '') 
		SELECT @CompanyAcceptable = ''
	ELSE
		SELECT @CompanyAcceptable = ' AND (cmp_id = ' + QUOTENAME(@CompanyID, '''') + ' OR cmp_id IS NULL OR cmp_id = ''UNKNOWN'')'

	IF (@MoveNumber = '') 
		SELECT @MovNumAcceptable = ''
	ELSE
		SELECT @MovNumAcceptable = ' AND (mov_number = ' + @MoveNumber + ' OR mov_number = 0 OR mov_number IS NULL)'
	
	IF (@LegNumber = '') 
		SELECT @LghNumAcceptable = ''
	ELSE
		SELECT @LghNumAcceptable = ' AND (lgh_number = ' + @LegNumber + ' OR lgh_number = 0 OR lgh_number IS NULL)'
	
	IF (@StopNumber = '') 
		SELECT @StpNumAcceptable = ''
	ELSE
		SELECT @StpNumAcceptable = ' AND (stp_number = ' + @StopNumber + ' OR stp_number = 0 OR stp_number IS NULL)'
	
	IF (@EquipType = '') 
		SELECT @EqpTypeAcceptable = ''
	ELSE
		SELECT @EqpTypeAcceptable = ' AND (lrq_equip_type = ' + QUOTENAME(@EquipType, '''') + ' OR lrq_equip_type IS NULL)'
	
	IF (@StopType = '') 
		SELECT @StpTypeAcceptable = ''
	ELSE
		SELECT @StpTypeAcceptable = ' AND (def_id_type = ' + QUOTENAME(@StopType, '''') + ' OR def_id_type = ''BOTH'' OR def_id_type IS NULL)'

	-- Finally, include matches for each provided item where all other filters are acceptable.
	IF (@OrdHdrNumber <> '')
		SELECT @SQLWhere = @SQLWhere + ' OR (ord_hdrnumber = ' + @OrdHdrNumber + @CompanyAcceptable + @MovNumAcceptable + @LghNumAcceptable + @StpNumAcceptable + @EqpTypeAcceptable + @StpTypeAcceptable + ')'

	IF (@CompanyID <> '')
		SELECT @SQLWhere = @SQLWhere + ' OR (cmp_id = ' + QUOTENAME(@CompanyID, '''') + @OrdHdrAcceptable + @MovNumAcceptable + @LghNumAcceptable + @StpNumAcceptable + @EqpTypeAcceptable + @StpTypeAcceptable + ')'

	IF (@MoveNumber <> '')
		SELECT @SQLWhere = @SQLWhere + ' OR (mov_number = ' + @MoveNumber + @OrdHdrAcceptable + @CompanyAcceptable + @LghNumAcceptable + @StpNumAcceptable + @EqpTypeAcceptable + @StpTypeAcceptable + ')'

	IF (@LegNumber <> '')
		SELECT @SQLWhere = @SQLWhere + ' OR (lgh_number = ' + @LegNumber + @OrdHdrAcceptable + @CompanyAcceptable + @MovNumAcceptable + @StpNumAcceptable + @EqpTypeAcceptable + @StpTypeAcceptable + ')'

	IF (@StopNumber <> '')
		SELECT @SQLWhere = @SQLWhere + ' OR (stp_number = ' + @StopNumber + @OrdHdrAcceptable + @CompanyAcceptable + @MovNumAcceptable + @LghNumAcceptable + @EqpTypeAcceptable + @StpTypeAcceptable + ')'

	IF (@EquipType <> '')
		SELECT @SQLWhere = @SQLWhere + ' OR (lrq_equip_type = ' + QUOTENAME(@EquipType, '''') + @OrdHdrAcceptable + @CompanyAcceptable + @MovNumAcceptable + @LghNumAcceptable + @StpNumAcceptable + @StpTypeAcceptable + ')'  --PTS 76938 - Fix QUOTENAME

	IF @scomm <> ''
		SELECT @SQLWhere = @SQLWhere + ' OR (cmd_code IN (' + @sComm + ')' + @OrdHdrAcceptable + @CompanyAcceptable + @MovNumAcceptable + @LghNumAcceptable + @StpNumAcceptable + @StpTypeAcceptable + ')'

	SELECT @SQLBase = @SQLBase + @SQLWhere

	EXEC(@SQLBase)
GO
GRANT EXECUTE ON  [dbo].[tmail_GetLoadRequirement] TO [public]
GO

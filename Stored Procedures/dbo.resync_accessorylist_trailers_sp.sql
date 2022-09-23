SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- ************************************************************************************************************
-- PTS 18488 -- BL
--
-- Procedure will re-sync the 'trl_accessorylist' field on the 'trailerprofile' table with the entries
--	for the associated trailers on the 'trlaccessories' table
--	(the 'trl_accessorylist' field is used as part of the resource filter on the Trip Planner window in Visual Dispatch)
-- ************************************************************************************************************
CREATE   PROCEDURE [dbo].[resync_accessorylist_trailers_sp]
AS
DECLARE @accessorylist varchar(254),
	@nextaccessory varchar(10),
	--DPH PTS 23856
	--@nexttrailer varchar(12)
	@nexttrailer varchar(13),
	--DPH PTS 23856
-- PTS 25023 -- BL (start)
	@begin_date datetime
-- PTS 25023 -- BL (end)

begin	
-- PTS 25023 -- BL (start)
	SELECT @begin_date = DATEADD(day, -30, getdate())

	-- Let the IUT Trigger update the 'accessory_list' column
	--	on the according asset table
 	update trlaccessories
	set ta_expire_flag = 'Y'
	where (ta_expire_date < getdate()
	and ta_expire_date >= @begin_date)
	AND (ta_expire_flag <> 'Y'
	or ta_expire_flag is NULL)
-- PTS 25023 -- BL (end)

-- PTS 25023 -- BL (start)
--     (comment out)
--   SELECT @nexttrailer = min(ta_trailer) from trlaccessories
--
--   -- If no records on table, leave proc
--   If @nexttrailer is null RETURN
--
--   WHILE 1=1
--   BEGIN
--	   SELECT @nextaccessory = '',
--		  @accessorylist = ''
--
--	   WHILE 1=1
--	   BEGIN
--		-- Get next accessory for current trailer
--		SELECT @nextaccessory = min(ta_type)
--		FROM	trlaccessories
--		WHERE	ta_type > @nextaccessory AND
--			ta_trailer = @nexttrailer
--		and ta_expire_date >= getdate()
--	
--		If @nextaccessory is null BREAK
--		SELECT @accessorylist = @accessorylist + ',,' + @nextaccessory
--	   END
--
--	SELECT @accessorylist = @accessorylist + ',,'
--	
--	UPDATE trailerprofile
--	SET	trl_accessorylist = @accessorylist
--	WHERE	trailerprofile.trl_number  = @nexttrailer AND
--		@accessorylist <> IsNull(trl_accessorylist, '')
--
--	-- Get next trailer on table
--	SELECT @nexttrailer = min(ta_trailer)
--	FROM trlaccessories
--	WHERE ta_trailer > @nexttrailer
--
--	If @nexttrailer is null BREAK
--   END
-- PTS 25023 -- BL (end)
	  
end 


GO
GRANT EXECUTE ON  [dbo].[resync_accessorylist_trailers_sp] TO [public]
GO

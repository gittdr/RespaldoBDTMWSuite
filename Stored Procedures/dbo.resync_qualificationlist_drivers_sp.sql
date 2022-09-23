SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- ************************************************************************************************************
-- PTS 18488 -- BL
--
-- Procedure will re-sync the 'mpp_qualificationlist' field on the 'manpowerprofile' table with the entries
--	for the associated drivers on the 'driverqualifications' table
--	(the 'mpp_qualificationlist' field is used as part of the resource filter on the Trip Planner window in Visual Dispatch)
-- ************************************************************************************************************
CREATE   PROCEDURE [dbo].[resync_qualificationlist_drivers_sp]
AS
DECLARE @qualificationlist varchar(254),
	@nextqualification varchar(10),
	@nextdriver varchar(12),
-- PTS 25023 -- BL (start)
	@begin_date datetime
-- PTS 25023 -- BL (end)

begin	
-- PTS 25023 -- BL (start)
	SELECT @begin_date = DATEADD(day, -30, getdate())

	-- Let the IUT Trigger update the 'accessory_list' column
	--	on the according asset table
 	update driverqualifications
	set drq_expire_flag = 'Y'
	where (drq_expire_flag < getdate()
	and drq_expire_flag >= @begin_date)
	AND (drq_expire_flag <> 'Y'
	or drq_expire_flag is NULL)
-- PTS 25023 -- BL (end)

-- PTS 25023 -- BL (start)
--     (comment out)
--   SELECT @nextdriver = min(drq_driver) from driverqualifications
--
--   -- If no records on table, leave proc
--   If @nextdriver is null RETURN
--
--   WHILE 1=1
--   BEGIN
--	   SELECT @nextqualification = '',
--		  @qualificationlist = ''
--
--	   WHILE 1=1
--	   BEGIN
--		-- Get next qualification for current driver
--		SELECT @nextqualification = min(drq_type)
--		FROM	driverqualifications
--		WHERE	drq_type > @nextqualification AND
--			drq_driver = @nextdriver
--		and drq_expire_date >= getdate()
--	
--		If @nextqualification is null BREAK
--		SELECT @qualificationlist = @qualificationlist + ',,' + @nextqualification
--	   END
--
--	SELECT @qualificationlist = @qualificationlist + ',,'
--	
--	UPDATE manpowerprofile
--	SET	mpp_qualificationlist = @qualificationlist
--	WHERE	manpowerprofile.mpp_id  = @nextdriver AND
--		@qualificationlist <> IsNull(mpp_qualificationlist, '')
--
--	-- Get next driver on table
--	SELECT @nextdriver = min(drq_driver)
--	FROM driverqualifications
--	WHERE drq_driver > @nextdriver
--
--	If @nextdriver is null BREAK
--   END
-- PTS 25023 -- BL (end)
	  
end 


GO
GRANT EXECUTE ON  [dbo].[resync_qualificationlist_drivers_sp] TO [public]
GO

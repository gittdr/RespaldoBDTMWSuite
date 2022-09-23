SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- ************************************************************************************************************
-- PTS 18488 -- BL
--
-- Procedure will re-sync the 'trc_accessorylist' field on the 'tractorprofile' table with the entries
--	for the associated tractors on the 'tractoraccesories' table
--	(the 'trc_accessorylist' field is used as part of the resource filter on the Trip Planner window in Visual Dispatch)
-- ************************************************************************************************************
CREATE   PROCEDURE [dbo].[resync_accessorylist_tractors_sp]
AS
DECLARE @accessorylist varchar(254),
	@nextaccessory varchar(10),
	@nexttractor varchar(12),
-- PTS 25023 -- BL (start)
	@begin_date datetime
-- PTS 25023 -- BL (end)

begin	
-- PTS 25023 -- BL (start)
	SELECT @begin_date = DATEADD(day, -30, getdate())

	-- Let the IUT Trigger update the 'accessory_list' column
	--	on the according asset table
 	update tractoraccesories
	set tca_expire_flag = 'Y'
	where (tca_expire_date < getdate()
	and tca_expire_date >= @begin_date)
	AND (tca_expire_flag <> 'Y'
	or tca_expire_flag is NULL)
-- PTS 25023 -- BL (end)

-- PTS 25023 -- BL (start)
--     (comment out)
--   SELECT @nexttractor = min(tca_tractor) from tractoraccesories
--
--   -- If no records on table, leave proc
--   If @nexttractor is null RETURN
--
--   WHILE 1=1
--   BEGIN
--	   SELECT @nextaccessory = '',
--		  @accessorylist = ''
--
--	   WHILE 1=1
--	   BEGIN
--		-- Get next accessory for current tractor
--		SELECT @nextaccessory = min(tca_type)
--		FROM	tractoraccesories
--		WHERE	tca_type > @nextaccessory AND
--			tca_tractor = @nexttractor
--		and tca_expire_date >= getdate()
--	
--		If @nextaccessory is null BREAK
--		SELECT @accessorylist = @accessorylist + ',,' + @nextaccessory
--	   END
--
--	SELECT @accessorylist = @accessorylist + ',,'
--	
--	UPDATE tractorprofile
--	SET	trc_accessorylist = @accessorylist
--	WHERE	tractorprofile.trc_number  = @nexttractor AND
--		@accessorylist <> IsNull(trc_accessorylist, '')
--
--	-- Get next tractor on table
--	SELECT @nexttractor = min(tca_tractor)
--	FROM tractoraccesories
--	WHERE tca_tractor > @nexttractor
--
--	If @nexttractor is null BREAK
--   END
-- PTS 25023 -- BL (end)
	  
end 


GO
GRANT EXECUTE ON  [dbo].[resync_accessorylist_tractors_sp] TO [public]
GO

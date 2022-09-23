SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 46682 JJF 20110515
CREATE PROCEDURE [dbo].[intercompany_ico_sync_parent_to_child_sp]	(
	@mov_number_parent int
) 

AS BEGIN
	--Push changes on parent trips to child
	--In this case, the only change is when assets change on parent.  When this occurs, the link breaks and the child order cancels

	--PTS 59888 JJF 20111031 deprecated
	RETURN
	
	--DECLARE @mov_number_child int

	--IF EXISTS	(	SELECT	*
	--				FROM	stops stp_p
	--				WHERE	stp_p.mov_number = @mov_number_parent
	--						and stp_p.stp_ico_stp_number_child > 0
	--			) BEGIN

	--	SELECT DISTINCT	@mov_number_child = stp_c.mov_number
	--	FROM	stops stp_c
	--			INNER JOIN stops stp_p on stp_c.stp_number = stp_p.stp_ico_stp_number_child
	--	WHERE	stp_p.mov_number = @mov_number_parent
	--			and stp_p.stp_ico_stp_number_child > 0

	--	UPDATE	orderheader
	--	SET		ord_status = 'CAN'
	--	WHERE	mov_number = @mov_number_child
		

		--UPDATE	stops
		--SET		stp_ico_stp_number_parent = null
		--WHERE	stops.mov_number = @mov_number_child
		--
		--UPDATE	stops
		--SET		stp_ico_stp_number_child = null
		--WHERE	stops.mov_number = @mov_number_parent
		--END PTS 59888 JJF 20111031 
		
--		EXEC update_move @mov_number_child

--	END
END
GO
GRANT EXECUTE ON  [dbo].[intercompany_ico_sync_parent_to_child_sp] TO [public]
GO

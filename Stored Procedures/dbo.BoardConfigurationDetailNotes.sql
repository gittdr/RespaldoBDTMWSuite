SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[BoardConfigurationDetailNotes] @lgh_number int
as
  SELECT  notes.not_text ,           
		notes.last_updatedby ,           
		notes.last_updatedatetime ,           
		notes.not_sequence ,           
		notes.nre_tablekey ,           
		notes.not_expires ,           
		notes.not_type ,           
		notes.not_urgent, 
		lgh_number     
	FROM assetassignment join notes on notes.nre_tablekey = asgn_id
where asgn_type = 'DRV' and notes.ntb_table = 'manpowerprofile' and lgh_number = @lgh_number
union
  SELECT  notes.not_text ,           
		notes.last_updatedby ,           
		notes.last_updatedatetime ,           
		notes.not_sequence ,           
		notes.nre_tablekey ,           
		notes.not_expires ,           
		notes.not_type ,           
		notes.not_urgent, 
		lgh_number     
	FROM assetassignment join notes on notes.nre_tablekey = asgn_id
where asgn_type = 'TRC' and notes.ntb_table = 'Tractorprofile' and lgh_number = @lgh_number
union
  SELECT  distinct notes.not_text ,           
		notes.last_updatedby ,           
		notes.last_updatedatetime ,           
		notes.not_sequence ,           
		notes.nre_tablekey ,           
		notes.not_expires ,           
		notes.not_type ,           
		notes.not_urgent, 
		lgh_number     
	FROM stops join notes on notes.nre_tablekey = ord_hdrnumber
where notes.ntb_table = 'orderheader' and stops.lgh_number = @lgh_number
GO
GRANT EXECUTE ON  [dbo].[BoardConfigurationDetailNotes] TO [public]
GO

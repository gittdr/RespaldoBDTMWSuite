SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[insert_dip_history_sp]
	@p_tank_nbr		int,
	@p_dl_date		datetime,
	@p_dl_dipreading	int,
	@p_dl_source		varchar(6),
	@p_dl_updatedby		varchar(20),
	@p_dl_updatedon		datetime,
        @p_dl_salesvolume       int
AS	

/**
 * 
 * NAME:
 * insert_dip_history_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Inserts a record into the diplog table based on the parameters received
 *     called from ue_save event on ps_w_diprecord to store diplog readings
 *
 * RETURNS: NONE
 *
 * RESULT SETS:  NONE
 *
 * PARAMETERS:
 * @p_tank_nbr		int		Foreign key to tank table
 * @p_dl_date		datetime	date/time of dip reading
 * @p_dl_dipreading	int		Value of dip reading
 * @p_dl_source		varchar(6)	Identifies where the dip reading originated.
 * 					TM = Totalmail, TL = Trailer Loading, IMP = Import File
 * 					FMW = Fuel Management System UI
 * @p_dl_updatedby	varchar(20)	Login ID of user who entered the reading
 * @p_dl_updatedon	datetime	date/time the reading was recorded
 * @p_dl_salesvolume    int             computed sales between prior diplog and the dip 
 *                                      recorded on this pw_w_diprecord window
 *
 * REVISION HISTORY:
 * 08/22/2005.01 ? PTS28806 - Dan Hudec ? Created Procedure
 * 04/13/2006.02 - PTS 32542 - D Petersen - Modify to update sales amount
 *
 **/

BEGIN

INSERT INTO diplog (tank_nbr, dl_date, dl_dipreading, dl_source, dl_updatedby, dl_updatedon,dl_delivervolume,dl_salesvolume)
VALUES (@p_tank_nbr, @p_dl_date, @p_dl_dipreading, @p_dl_source, @p_dl_updatedby, @p_dl_updatedon,0,@p_dl_salesvolume)

END
GO
GRANT EXECUTE ON  [dbo].[insert_dip_history_sp] TO [public]
GO

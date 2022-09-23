SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi214_create_pending_sp] @ord_hdrnumber INT, @profileid int
	
AS
BEGIN
	declare @stp_sequence int, @stp_number int, @est_arrival datetime 

	SELECT @stp_sequence = MIN(stp_sequence)
				FROM stops
			       WHERE ord_hdrnumber = @ord_hdrnumber AND
				     stp_type = 'PUP'

			      SELECT @stp_number = stp_number,
				     @est_arrival = stp_arrivaldate
				FROM stops
			       WHERE ord_hdrnumber = @ord_hdrnumber AND
				     stp_sequence = @stp_sequence

			      INSERT edi_214_pending (
					e214p_ord_hdrnumber,
					e214p_billto,
					e214p_level,
					e214p_ps_status,
					e214p_stp_number,
					e214p_dttm,
					e214p_activity,
					e214p_arrive_earlyorlate,
					e214p_depart_earlyorlate,
					e214p_stpsequence,
					ckc_number,
					e214p_firstlastflags,
					e214p_created)
			         SELECT DISTINCT 
				        @ord_hdrnumber,
				        e214_cmp_id,
				        e.e214_level,
				        ' ',
				        @stp_number,
				        @est_arrival,
				        e.e214_triggering_activity,
						'',
				        e.e214_stp_position,
				        @stp_sequence,
				        0,
				        '0,1,99',
				        GETDATE()
				   FROM orderheader JOIN edi_214_profile e ON e.e214_id = @profileid
				  WHERE ord_hdrnumber = @ord_hdrnumber
END

GO
GRANT EXECUTE ON  [dbo].[edi214_create_pending_sp] TO [public]
GO

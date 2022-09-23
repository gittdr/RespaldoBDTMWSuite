SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_AutoCreateLateServiceExcpetion_sp]
(
  @inserted     UtStopsConsolidated READONLY,
  @deleted      UtStopsConsolidated READONLY,
  @SELate       CHAR(1),
  @SELateDepart CHAR(1),
  @SEAsset      VARCHAR(6)
)
AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF @SELate = 'Y'
  INSERT INTO dbo.serviceexception
    (
      sxn_stp_number,
      sxn_asgn_type,
      sxn_asgn_id,
      sxn_expcode,
      sxn_expdate,
      sxn_mov_number,
      sxn_createdby,
      sxn_createddate,
      sxn_affectspay,
      sxn_actioncode,
      sxn_description,
      sxn_ord_hdrnumber,
      sxn_cmp_id,
      sxn_cty_code,
      sxn_action_description,
      sxn_delete_flag,
      sxn_late,
      sxn_contact_customer,
      sxn_action_received
    )
    SELECT  i.stp_number,
            @SEAsset,
            CASE @SEAsset
              WHEN 'TRC' THEN e.evt_tractor
              WHEN 'DRV' THEN e.evt_driver1
              WHEN 'TRL' THEN e.evt_trailer1
              WHEN 'CAR' THEN e.evt_carrier
              ELSE 'UNK'
            END,
            i.stp_reasonlate,
            i.last_updatedate,
            i.mov_number,
            i.last_updateby,
            i.last_updatedate,
            'N',
            'UNK',
            i.stp_reasonlate_text,
            i.ord_hdrnumber,
            i.cmp_id,
            i.stp_city,
            '',
            'N',
            'UNK',
            'N',
            'N'
      FROM  @inserted i
              INNER JOIN @deleted d ON d.stp_number = i.stp_number
              INNER JOIN dbo.event e WITH(NOLOCK) ON e.stp_number = i.stp_number AND e.evt_sequence = 1
     WHERE  i.stp_reasonlate <> d.stp_reasonlate
       AND  i.ord_hdrnumber <> 0;

IF @SELateDepart = 'Y'
  INSERT INTO serviceexception 
		(
      sxn_stp_number, 
			sxn_asgn_type,
			sxn_asgn_id, 
			sxn_expcode, 
			sxn_expdate, 
			sxn_mov_number, 
			sxn_createdby, 
			sxn_createddate, 
			sxn_affectspay, 
			sxn_actioncode, 
			sxn_description,
			sxn_ord_hdrnumber,
			sxn_cmp_id, 
			sxn_cty_code,
			sxn_action_description,
			sxn_delete_flag,
			sxn_late,
			sxn_contact_customer,
			sxn_action_received
    )
		SELECT  i.stp_number, 
            @SEAsset,
            CASE @SEAsset
						  WHEN 'TRC' THEN e.evt_tractor
						  WHEN 'DRV' THEN e.evt_driver1
						  WHEN 'TRL' THEN e.evt_trailer1
						  WHEN 'CAR' THEN e.evt_carrier
						  ELSE 'UNK'
					  END,
  					i.stp_reasonlate_depart,
	  				i.last_updatedatedepart, 
		  			i.mov_number,
			  		i.last_updatebydepart, 
				  	i.last_updatedatedepart, 
					  'N', 
					  'UNK',
					  i.stp_reasonlate_depart_text,
					  i.ord_hdrnumber, 
					  i.cmp_id, 
					  i.stp_city,
					  '',
					  'N',
					  'UNK',
					  'N',
					  'N'
      FROM  @inserted i 
              INNER JOIN @deleted d ON d.stp_number = i.stp_number
              INNER JOIN event e WITH(NOLOCK) on e.stp_number = i.stp_number AND e.evt_sequence = 1
		 WHERE  i.stp_reasonlate_depart <> d.stp_reasonlate_depart
       AND  i.ord_hdrnumber <> 0;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_AutoCreateLateServiceExcpetion_sp] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_DipHistory_sp]
(
  @inserted UtStopsConsolidated READONLY,
  @deleted  UtStopsConsolidated READONLY
)
AS

SET NOCOUNT ON;

WITH NewVol AS 
(
  SELECT  i.ord_hdrnumber,
          fbc.fbc_tank_nbr,
          SUM(COALESCE(fbc.fbc_volume , 0)) NewVolume
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            INNER JOIN dbo.freight_by_compartment fbc WITH(NOLOCK) ON fbc.stp_number = i.stp_number
            INNER JOIN dbo.compinvprofile cip WITH(NOLOCK) ON cip.cmp_id = i.cmp_id
   WHERE  i.stp_status <> d.stp_status
     AND  i.stp_status = 'DNE'
     AND  i.stp_type = 'DRP'
  GROUP BY i.ord_hdrnumber, fbc.fbc_tank_nbr
	UNION
	SELECT  i.ord_hdrnumber,
          fbc.fbc_tank_nbr,
          0 NewVolume
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            INNER JOIN dbo.freight_by_compartment fbc WITH(NOLOCK) ON fbc.stp_number = i.stp_number
            INNER JOIN dbo.compinvprofile cip WITH(NOLOCK) ON cip.cmp_id = i.cmp_id
   WHERE  i.stp_status <> d.stp_status
     AND  i.stp_status = 'OPN'
     AND  i.stp_type = 'DRP'
  GROUP BY i.ord_hdrnumber, fbc.fbc_tank_nbr

)
UPDATE  dbo.tankdiphistory
   SET  tank_deliveredqty = NewVolume
  FROM  NewVol
 WHERE  tankdiphistory.ord_hdrnumber = NewVol.ord_hdrnumber
   AND  tankdiphistory.tank_nbr = NewVol.fbc_tank_nbr;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_DipHistory_sp] TO [public]
GO

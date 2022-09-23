SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[d_martintrans_billoflading] (@ordnum int)
AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/26/2007.01 ? PTS40189 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

SELECT       
       ORD.ORD_NUMBER ORDER_NO,       
       --ISNULL(REVTYPE1.NAME,'')TERMINAL1,
       case 
       	        when revtype1.name = 'UNKNOWN' then ''
       		else isnull(revtype1.name,'')
       	        end TERMINAL1,	
       --ISNULL(REVTYPE2.NAME,'')PICKED_UP,
	case 
       	        when revtype2.name = 'UNKNOWN' then ''
       		else isnull(revtype2.name,'')
       	        end PICKED_UP,	
       --ISNULL(REVTYPE3.NAME,'') DELIVERED_TO, 
       case 
       	        when revtype3.name = 'UNKNOWN' then ''
       		else isnull(revtype3.name,'')
       	        end DELIVERED_TO,	     
       ORD.ORD_ORIGIN_EARLIESTDATE PICKUPDATE,
       ORD.ORD_DEST_EARLIESTDATE DELIVERYDATE,
       ISNULL(CMD.CMD_DOT_NAME,'') SHIPPING_TECH_NAME,
       CMD.CMD_NAME SPECIAL_INSTRUCTIONS,      
       ISNULL(CMD.CMD_HAZ_CLASS,'') HAZ_CLASS,
       ISNULL(CMD.CMD_HAZ_SUBCLASS,'') PKG_GRP,
       ISNULL(CMD.CMD_HAZ_NUM,'') ID_NUMBER,
       --ISNULL(CMD.CMD_MIN_SPILL,0) RQ,
       case 
       	        when CMD.CMD_MIN_SPILL > 0 then 'X'
       		else ''
       	        end RQ,
       --ISNULL(TRLPROFILE.TRL_MISC4,'0') NET_WEIGHT ,
       '1 TL' NET_WEIGHT,
       shipper.cmp_name shipper_name ,
       shipper_cty.cty_name shipper_cty_name,
       shipper_cty.cty_state shipper_cty_state,
       consignee.cmp_name consignee_name,
       consignee_cty.cty_name consignee_cty_name,
       consignee_cty.cty_state consignee_cty_state,
       BILLTO.cmp_name billto_name,
       LGH.LGH_PRIMARY_TRAILER TRAILER,
       LGH.LGH_TRACTOR TRACTOR     
--pts40189 outer join conversion       
FROM orderheader ord  LEFT OUTER JOIN  company shipper  ON  ORD.ord_shipper  = shipper.cmp_id   
		LEFT OUTER JOIN  company consignee  ON  ORD.ord_consignee  = consignee.cmp_id   
		LEFT OUTER JOIN  company billto  ON  ORD.ord_billto  = billto.cmp_id   
		LEFT OUTER JOIN  city consignee_cty  ON  ORD.ORD_destcity  = consignee_cty.cty_code   
		LEFT OUTER JOIN  city shipper_cty  ON  ORD.ORD_origincity  = shipper_cty.cty_code   
		LEFT OUTER JOIN  labelfile revtype2  ON  (ORD.ORD_REVTYPE2  = REVTYPE2.ABBR and REVTYPE2.LABELDEFINITION = 'RevType2')
		LEFT OUTER JOIN  labelfile revtype3  ON  (ORD.ORD_REVTYPE3  = REVTYPE3.ABBR and REVTYPE3.LABELDEFINITION = 'RevType3')
		LEFT OUTER JOIN  labelfile revtype1  ON  (ORD.ORD_BOOKED_REVTYPE1  = REVTYPE1.ABBR and REVTYPE1.LABELDEFINITION = 'RevType1') ,
	 trailerprofile trlprofile,
	 commodity cmd,
	 legheader lgh     
WHERE ORD.ORD_HDRNUMBER  = @ordnum      AND
      ORD.CMD_CODE       = CMD.CMD_CODE AND      
      LGH.ORD_HDRNUMBER  = ORD.ORD_HDRNUMBER AND
      (LGH.LGH_PRIMARY_TRAILER = TRLPROFILE.TRL_ID AND TRLPROFILE.TRL_NUMBER <> 'UNKNOWN')

GO
GRANT EXECUTE ON  [dbo].[d_martintrans_billoflading] TO [public]
GO

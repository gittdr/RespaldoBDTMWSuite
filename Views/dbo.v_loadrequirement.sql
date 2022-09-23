SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  View dbo.v_loadrequirement    Script Date: 6/1/99 11:54:01 AM ******/
/****** Object:  View dbo.v_loadrequirement    Script Date: 12/10/97 1:56:59 PM ******/
/****** Object:  View dbo.v_loadrequirement    Script Date: 4/17/97 3:25:42 PM ******/
CREATE VIEW [dbo].[v_loadrequirement]  
    ( ord_hdrnumber,   
      lrq_sequence,   
      lrq_equip_type,   
      lrq_type,   
      lrq_not,   
      lrq_manditory,   
      lrq_quantity ) AS   
  SELECT loadrequirement.ord_hdrnumber,   
         loadrequirement.lrq_sequence,   
         loadrequirement.lrq_equip_type,   
         loadrequirement.lrq_type,   
         loadrequirement.lrq_not,   
         loadrequirement.lrq_manditory,   
         loadrequirement.lrq_quantity  
    FROM loadrequirement   



GO
GRANT DELETE ON  [dbo].[v_loadrequirement] TO [public]
GO
GRANT INSERT ON  [dbo].[v_loadrequirement] TO [public]
GO
GRANT REFERENCES ON  [dbo].[v_loadrequirement] TO [public]
GO
GRANT SELECT ON  [dbo].[v_loadrequirement] TO [public]
GO
GRANT UPDATE ON  [dbo].[v_loadrequirement] TO [public]
GO

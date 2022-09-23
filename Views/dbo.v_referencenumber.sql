SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  View dbo.v_referencenumber    Script Date: 6/1/99 11:54:02 AM ******/
/****** Object:  View dbo.v_referencenumber    Script Date: 12/10/97 1:56:59 PM ******/
/****** Object:  View dbo.v_referencenumber    Script Date: 4/17/97 3:25:49 PM ******/
CREATE VIEW [dbo].[v_referencenumber]  
    ( ref_tablekey,   
      ref_type,   
      ref_number,   
      ref_typedesc,   
      ref_sequence,   
      ord_hdrnumber,   
      ref_table,   
      ref_sid,   
      ref_pickup ) AS   
  SELECT referencenumber.ref_tablekey,   
         referencenumber.ref_type,   
         referencenumber.ref_number,   
         referencenumber.ref_typedesc,   
         referencenumber.ref_sequence,   
         referencenumber.ord_hdrnumber,   
         referencenumber.ref_table,   
         referencenumber.ref_sid,   
         referencenumber.ref_pickup  
    FROM referencenumber   



GO
GRANT DELETE ON  [dbo].[v_referencenumber] TO [public]
GO
GRANT INSERT ON  [dbo].[v_referencenumber] TO [public]
GO
GRANT REFERENCES ON  [dbo].[v_referencenumber] TO [public]
GO
GRANT SELECT ON  [dbo].[v_referencenumber] TO [public]
GO
GRANT UPDATE ON  [dbo].[v_referencenumber] TO [public]
GO

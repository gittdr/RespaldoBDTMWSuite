SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  View dbo.v_notes    Script Date: 6/1/99 11:54:02 AM ******/
/****** Object:  View dbo.v_notes    Script Date: 12/10/97 1:56:59 PM ******/
/****** Object:  View dbo.v_notes    Script Date: 4/17/97 3:25:44 PM ******/
CREATE VIEW [dbo].[v_notes]  
    ( not_number,   
      not_text,   
      not_type,   
      not_urgent,   
      not_senton,   
      not_sentby,   
      not_expires,   
      not_forwardedfrom,   
      ntb_table,   
      nre_tablekey,   
      not_sequence ) AS   
  SELECT notes.not_number,   
         notes.not_text,   
         notes.not_type,   
         notes.not_urgent,   
         notes.not_senton,   

         notes.not_sentby,   
         notes.not_expires,   
         notes.not_forwardedfrom,   
         notes.ntb_table,   
         notes.nre_tablekey,   
         notes.not_sequence  
    FROM notes   



GO
GRANT DELETE ON  [dbo].[v_notes] TO [public]
GO
GRANT INSERT ON  [dbo].[v_notes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[v_notes] TO [public]
GO
GRANT SELECT ON  [dbo].[v_notes] TO [public]
GO
GRANT UPDATE ON  [dbo].[v_notes] TO [public]
GO

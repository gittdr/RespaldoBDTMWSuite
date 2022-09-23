SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  View dbo.v_freightdetail    Script Date: 6/1/99 11:54:01 AM ******/
/****** Object:  View dbo.v_freightdetail    Script Date: 12/10/97 1:56:59 PM ******/
/****** Object:  View dbo.v_freightdetail    Script Date: 4/17/97 3:25:36 PM ******/
CREATE VIEW [dbo].[v_freightdetail]  
    ( fgt_number,   
      cmd_code,   
      fgt_weight,   
      fgt_weightunit,   
      fgt_description,   
      stp_number,   
      fgt_count,   
      fgt_countunit,   
      fgt_volume,   
      fgt_volumeunit,   
      fgt_lowtemp,   
      fgt_hitemp,   
      fgt_sequence,   
      fgt_length,   
      fgt_lengthunit,   
      fgt_height,   
      fgt_heightunit,   
      fgt_width,   
      fgt_widthunit,   
      fgt_reftype,   
      fgt_refnum ) AS   
  SELECT freightdetail.fgt_number,   
         freightdetail.cmd_code,   
         freightdetail.fgt_weight,   
         freightdetail.fgt_weightunit,   
         freightdetail.fgt_description,   
         freightdetail.stp_number,   
         freightdetail.fgt_count,   
         freightdetail.fgt_countunit,   
         freightdetail.fgt_volume,   
         freightdetail.fgt_volumeunit,   
         freightdetail.fgt_lowtemp,   
         freightdetail.fgt_hitemp,   
         freightdetail.fgt_sequence,   
         freightdetail.fgt_length,   
         freightdetail.fgt_lengthunit,   
         freightdetail.fgt_height,   
         freightdetail.fgt_heightunit,   
         freightdetail.fgt_width,   
         freightdetail.fgt_widthunit,   
         freightdetail.fgt_reftype,   
         freightdetail.fgt_refnum  
    FROM freightdetail   



GO
GRANT DELETE ON  [dbo].[v_freightdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[v_freightdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[v_freightdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[v_freightdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[v_freightdetail] TO [public]
GO

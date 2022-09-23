SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


/*
  created 9/8/00 pts 8848 to add a tag for the end of a trans set (tells us it is all there)
              implemented starting in v3.9
   PTS 70732 2.17.14 - updated to correct recompile issue.           
*/
CREATE PROCEDURE [dbo].[edi_214_record_id_end_sp] 
			@TPNumber varchar(20),
			@docid varchar(30)

 as
 DECLARE @Count214 INT
 
 SELECT @Count214 = COUNT(*) FROM EDI_214 WITH(NOLOCK) WHERE doc_id = @docid

--IF(SELECT COUNT(*) FROM edi_214 WHERE doc_id = @docid) > 0
IF @Count214 > 0
INSERT edi_214 (data_col,trp_id,doc_id)
     SELECT 
      data_col = 'END',
      trp_id = @TPNumber, doc_id = @docid		
 

GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_end_sp] TO [public]
GO

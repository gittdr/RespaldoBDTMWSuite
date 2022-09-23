SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[cdfuelbill_mappings] 
AS 
SELECT cfb_xfacetype, 
		 cfb_code, 
		 cfb_mappingdescription, 
		 cfb_columnname, 
		 cfb_paytype 
  FROM cdfuelbill_mappings_tbl 
GO
GRANT DELETE ON  [dbo].[cdfuelbill_mappings] TO [public]
GO
GRANT INSERT ON  [dbo].[cdfuelbill_mappings] TO [public]
GO
GRANT SELECT ON  [dbo].[cdfuelbill_mappings] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdfuelbill_mappings] TO [public]
GO

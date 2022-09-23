SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[MobileTrailersView_TDR]
AS
     SELECT 'TMWWF_MOBILE_TRAILERS' AS 'TMWWF_MOBILE_TRAILERS',
            LTRIM(trl_number) AS 'ID',
            LTRIM(trl_number) AS 'Name',
            LTRIM(trl_type1) AS 'TrlType1', 'TrlType1 Name' = COALESCE(LTRIM(L1.name), ''),
            LTRIM(trl_type2) AS 'TrlType2', 'TrlType2 Name' = COALESCE(LTRIM(L2.name), ''),
            LTRIM(trl_type3) AS 'TrlType3', 'TrlType3 Name' = COALESCE(LTRIM(L3.name), ''),
            LTRIM(trl_type4) AS 'TrlType4', 'TrlType4 Name' = COALESCE(LTRIM(L4.name), '')
     FROM dbo.trailerprofile T WITH (NOLOCK)
          LEFT OUTER JOIN labelfile L1 WITH (NOLOCK) ON T.trl_type1 = L1.abbr AND L1.labeldefinition = 'TrlType1'
          LEFT OUTER JOIN labelfile L2 WITH (NOLOCK) ON T.trl_type2 = L2.abbr AND L2.labeldefinition = 'TrlType2'
          LEFT OUTER JOIN labelfile L3 WITH (NOLOCK) ON T.trl_type3 = L3.abbr AND L3.labeldefinition = 'TrlType3'
          LEFT OUTER JOIN labelfile L4 WITH (NOLOCK) ON T.trl_type4 = L4.abbr AND L4.labeldefinition = 'TrlType4'
		  where  trl_status <> 'OUT'

GO

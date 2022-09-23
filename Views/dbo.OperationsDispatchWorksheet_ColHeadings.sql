SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[OperationsDispatchWorksheet_ColHeadings]
AS
SELECT	dv_id, 
		RevType1 ord_revtype1_t, 
		RevType2 ord_revtype2_t, 
		RevType3 ord_revtype3_t, 
		RevType4 ord_revtype4_t, 
		(select top 1 userlabelname from labelfile where labeldefinition = ISNULL(generalinfo.gi_string2, 'Branch')) ord_booked_revtype1_t, 
		(select top 1 userlabelname from labelfile where labeldefinition = ISNULL(generalinfo.gi_string3, 'Branch')) lgh_booked_revtype1_t, 
		dispatchview.dv_reference1_heading reference_col1_t, 
		dispatchview.dv_reference2_heading reference_col2_t, 
		CarType1 cartype1_t, 
		CarType2 cartype2_t, 
		CarType3 cartype3_t, 
		CarType4 cartype4_t, 
		TrlType1 trailer1_trltype1_t, 
		TrlType2 trailer1_trltype2_t, 
		TrlType3 trailer1_trltype3_t, 
		TrlType4 trailer1_trltype4_t, 
		TrlType1 trailer2_trltype1_t, 
		TrlType2 trailer2_trltype2_t, 
		TrlType3 trailer2_trltype3_t, 
		TrlType4 trailer2_trltype4_t, 
		LghType1 lgh_type1_t, 
		LghType2 lgh_type2_t, 
		(select top 1 userlabelname from labelfile where labeldefinition = 'LghType3') lgh_type3_t, 
		(select top 1 userlabelname from labelfile where labeldefinition = 'LghType4') lgh_type4_t,
		--PTS 63598 JJF 20121011
		(SELECT TOP 1 lbl.userlabelname FROM labelfile lbl WHERE lbl.labeldefinition = 'Company') as ord_subcompany_t
		--END PTS 63598 JJF 20121011
   FROM	dispatchview, 
        labelfile_headers, 
        generalinfo 
  WHERE	dispatchview.dv_type = 'DW' 
    AND generalinfo.gi_name = 'TrackBranch' 
GO
GRANT REFERENCES ON  [dbo].[OperationsDispatchWorksheet_ColHeadings] TO [public]
GO
GRANT SELECT ON  [dbo].[OperationsDispatchWorksheet_ColHeadings] TO [public]
GO

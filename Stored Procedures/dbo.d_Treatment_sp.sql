SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_Treatment_sp] @srpID int
As
/* 
SR 17782 DPETE created 10/13/03 for retrieving and maintaining Treatment information.  Brings back all for
    a safety report, must be filtered for an  injury within the incident
   2/6/4 remove medical restrictions (moved to injury)
*/



Select trt_ID,
   srp_ID,
   inj_sequence,  -- use trt_date for sequence, inj_sequ to link to injury
  trt_Date,
  trt_Facility = IsNull(trt_facility,''),
  trt_FacAddress1 = IsNull(trt_FacAddress1,''),
  trt_FacAddress2 = IsNull(trt_FacAddress2,''),
  trt_FacCity,
  trt_FacCtynmstct = IsNull(trt_FacCtynmstct,'UNKNOWN'),
  trt_FacState = IsNull(trt_FacState,''),
  trt_FacZip = IsNull(trt_FacZip,''),
  trt_FacCountry = IsNull(trt_FacCountry,''),
  trt_FacPhone = IsNull(trt_FacPhone,''),
  trt_CompanyFac,  -- 'Y', 'N' is treatment done at company facility
  trt_TreatedByType = IsNull(trt_treatedByType,'UNK'), trt_TreatedByType_t = 'TreatedByType',
  trt_Description = IsNull(trt_Description,''),
  trt_diagnosis =  IsNull(trt_diagnosis,''),
  trt_NextAppt,
  trt_TreatedByName = IsNull(trt_treatedByName,'')
From Treatment  
Where srp_Id =  @srpID
Order by trt_Date


GO
GRANT EXECUTE ON  [dbo].[d_Treatment_sp] TO [public]
GO

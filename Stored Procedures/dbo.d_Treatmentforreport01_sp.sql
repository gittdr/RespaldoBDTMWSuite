SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

 Create Proc [dbo].[d_Treatmentforreport01_sp] @srpID int  
As  

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
   SR 17782 DPETE created 1/14/04 for retrieving  Treatment information for an embedded report.  Brings back all for  
    a safety report  
   2/6/4 remove medical restrictions (moved to injury)
 * 11/07/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
  
  
Select trt_ID,  
   srp_ID,  
   Treatment.inj_sequence,  -- use trt_date for sequence, inj_sequ to link to injury  
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
  trt_TreatedByName = IsNull(trt_treatedByName,''),
  inj_name  
From Treatment LEFT OUTER JOIN (Select inj_sequence,inj_name From Injury  Where srp_id = @srpID) Inj ON Treatment.inj_sequence = inj.inj_sequence
Where Treatment.srp_Id =  @srpID 
Order by treatment.inj_sequence,trt_Date  
 
GO
GRANT EXECUTE ON  [dbo].[d_Treatmentforreport01_sp] TO [public]
GO

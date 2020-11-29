using ChoreStorefront.Core;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace ChoreStorefront.Model.Models
{
    [TsClassModule]
    public class User
    {
        [Key]
        public int Id { get; set; }
        [StringLength(255)]
        public string Username { get; set; }
        [StringLength(100)]
        public string FirstName { get; set; }
        [StringLength(100)]
        public string LastName { get; set; }
        [StringLength(255)]
        public string Password { get; set; }
    }
}

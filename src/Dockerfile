FROM tyrion75/fww-malware-test:20241010

# Copy a file into the image
COPY my_script.sh /usr/local/bin/

# Set permissions for the script
RUN chmod +x /usr/local/bin/my_script.sh

# Set the default command to run the script
CMD ["/usr/local/bin/my_script.sh"]
